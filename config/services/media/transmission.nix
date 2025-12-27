{ pkgs, lib, config, nodes, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption mkMerge;
  gservices = config.globals.services;
  cfg = config.glyph.media;
in
{
  imports = [
    ../acme.nix
    ../nginx-common.nix
    ../oauth2_proxy.nix
  ];

  options.glyph.media.transmission.enable = mkOption {
    description = "enable transmission";
    default = cfg.enable;
  };

  config = mkIf cfg.transmission.enable {
    assertions = [
      {
        assertion = cfg.enable;
        message = "Transmission requires nixarr to be enabled";
      }
    ];

    sops.secrets."mullvad.wg.conf" = {
      sopsFile = ../../../secrets/sops/vpn/mullvad.wg.conf;
      format = "binary";
    };

    nixarr = {
      vpn = {
        enable = true;
        #accessibleFrom = [
        #  "100.64.0.0/10"
        #  "fd7a:115c:a1e0::/48"
        #];
        wgConf = config.sops.secrets."mullvad.wg.conf".path;
        vpnTestService.enable = true;
      };

      transmission = {
        enable = true;
        peerPort = gservices.transmission.peerPort; # mullvad doesn't have forwarding
        stateDir = "/var/lib/transmission";
        vpn.enable = true;
        flood.enable = true;
        uiPort = gservices.flood.bindport;
        #credentialsFile = config.sops.secrets."transmission_credentials.json".path;
        messageLevel = "info";
        extraAllowedIps = [ gservices.headscale.myAddr ];
        extraSettings = {
          rpc-host-whitelist = "${gservices.flood.domain}";
          # we use sso via oauth2-proxy instead
          #rpc-authentication-required = true;
        };
      };
    };


    security.acme.certs."${gservices.flood.domain}" = {
      reloadServices = [ "nginx.service" ];
      group = "nginx";
    };

    security.acme.certs."auth.${gservices.flood.domain}" = {
      reloadServices = [ "nginx.service" ];
    };

    services.nginx = {
      virtualHosts."127.0.0.1:${toString gservices.flood.bindport}" = lib.mkForce {
        locations."/".return = "444";
      };
      virtualHosts."${gservices.flood.domain}" = gservices.nginx.mkReverseProxy {
        proto = "http";
        domain = config.services.transmission.settings.rpc-bind-address;
        port = gservices.flood.bindport;
        listen = [ gservices.headscale.myAddr ];
        acme_host = gservices.flood.domain;
      };
    };

    glyph.nginx.oauth2-gate."${gservices.flood.domain}" = {
      displayName = "Flood";
      port = gservices.flood.bindport + 1;
      allowed_groups = [ "flood_users@${gservices.kanidm.domain}" ];
      logo = ../../../assets/flood-logo.png;
      nginxListen = [ gservices.headscale.myAddr ];
    };

    glyph.transpose.headscale.dns = [
      (gservices.headscale.mkDnsEntry gservices.flood.host)
      (gservices.headscale.mkDnsEntry "auth.${gservices.flood.host}")
    ];
  };
}