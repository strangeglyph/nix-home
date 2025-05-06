{ config, lib, ... }:
with lib;
let
  cfg = config.services.glyphscale;
  headscale-domain = "${cfg.headscale-name}.${cfg.base-domain}";
  tailnet-domain = "${cfg.tailnet-name}.${cfg.base-domain}";
  acme-dns-domain = if (cfg.acme-override-domain != null) then cfg.acme-override-domain else cfg.base-domain;
  acme-domain = if cfg.acme-uses-dns then acme-dns-domain else config.security.acme.http-challenge-host;
in
{
  imports = [
    ./nginx-common.nix
  ];

  options.services.glyphscale = {
    enable = mkEnableOption "glyph headscale setup";
    base-domain = mkOption { type = types.str; description = "base domain on which the headscale domain and the tailnet domain are based on"; };
    headscale-name = mkOption { type = types.str; };
    tailnet-name = mkOption { type = types.str; };
    acme-uses-dns = mkOption { type = types.bool; default = true; };
    acme-override-domain = mkOption { 
      default = null;
      description = "Override acme host (optional, if not specified defaults to base-domain)";
    };
  };

  config = mkIf cfg.enable {
    users.groups.acme.members = [ "headscale" ];
    security.acme.certs = mkIf (! cfg.acme-uses-dns) {
      "${ config.security.acme.http-challenge-host }".extraDomainNames = [ headscale-domain ];
    };
    # for DERP
    networking.firewall.allowedUDPPorts = [ 3478 ];

    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        server_url = "https://${headscale-domain}";
        tls_cert_path = "${config.security.acme.certs.${acme-domain}.directory}/fullchain.pem";
        tls_key_path = "${config.security.acme.certs.${acme-domain}.directory}/key.pem";
        dns.base_domain = "${tailnet-domain}";
      };
    };


    services.nginx = {
      enable = true;
      virtualHosts."${headscale-domain}" = {
        forceSSL = true;
        useACMEHost = acme-domain;
        
        quic = true;
        http3 = true;
        # advertise quic support
        extraConfig = ''
          add_header Alt-Svc 'h3=":$server_port"; ma=86400';
        '';


        locations."/" = {
          proxyPass = "https://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
