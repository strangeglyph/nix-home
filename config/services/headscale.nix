{ config, lib, globals, ... }:
with lib;
let
  cfg = config.services.headscale;
  globals_hs = globals.services.headscale;
in
{
  imports = [
    ./nginx-common.nix
  ];

  options.glyph.headscale.enable = mkEnableOption {};

  config = mkIf config.glyph.headscale.enable {
    users.groups.acme.members = [ "headscale" ];
    
    age.secrets.kanidm_oauth_interstice = {
      file = ../agenix/kanidm_oauth_interstice.age;
      group = "oauth_interstice";
      mode = "0440";
    };
    # for self-hosted DERP
    #networking.firewall.allowedUDPPorts = [ 3478 ];

    services.headscale = {
      enable = true;
      address = globals_hs.bindaddr;
      port = globals_hs.bindport;
      settings = {
        server_url = "https://${globals_hs.domain}";
        tls_cert_path = globals.acmeChainPath;
        tls_key_path = globals.acmeKeyPath;
        dns = {
          base_domain = "${globals_hs.net.domain}";
        };
        oidc = {
          client_secret_path = config.age.secrets.kanidm_oauth_interstice.path;
          client_id = globals_hs.net.name;
          issuer = globals.services.kanidm.makeOidc globals_hs.net.name;
          pkce.enabled = true;
        };
      };
    };


    services.nginx = {
      enable = true;
      virtualHosts."${globals_hs.domain}" = {
        forceSSL = true;
        useACMEHost = globals.domains.base;
        
        quic = true;
        http3 = true;
        # advertise quic support
        extraConfig = ''
          add_header Alt-Svc 'h3=":$server_port"; ma=86400';
        '';


        locations."/" = {
          proxyPass = "https://${globals_hs.bindaddr}:${toString globals_hs.bindport}";
          proxyWebsockets = true;
        };
      };
    };
  };
}

