{ pkgs, config, lib, ... }:
let
  cfg = config.services.kanidm;
  acme = config.security.acme;
  domain = "${cfg.host}.${cfg.base-domain}";
in
{
  imports = [ ./nginx-common.nix ];

  options.services.kanidm = {
    enable = lib.mkEnableOption { description = "glyph kanidm setup"; };
    host = lib.mkOption { type = lib.types.str; description = "kanidm host name (sans base)"; };
    base-domain = lib.mkOption { type = lib.types.str; description = "kanidm base domain"; };
  };

  config = lib.mkIf cfg.enable {
    users.groups.acme.members = [ "kanidm" ];

    services.kanidm = {
      enableClient = true;
      clientSettings = {
        uri = cfg.serverSettings.origin;
      };

      enableServer = true; 
      serverSettings = {
        bindaddress = "[::1]:49741";
        ldapbindaddress = "[::1]:3636";
        trust_x_forward_for = true;
        domain = domain;
        origin = "https://${domain}";
        tls_chain = "${acme.certs.${cfg.base-domain}.directory}/fullchain.pem";
        tls_key = "${acme.certs.${cfg.base-domain}.directory}/key.pem";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."${domain}" = {
        forceSSL = true;
        useACMEHost = cfg.base-domain;
        
        quic = true;
        http3 = true;
        # advertise quic support
        extraConfig = ''
          add_header Alt-Svc 'h3=":$server_port"; ma=86400';
        '';

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "https://[::1]:49741";
        };
      };
    };
  };
}
