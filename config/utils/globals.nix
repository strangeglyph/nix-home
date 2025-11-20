{ lib, config, nodes, ... }:
let 
  inherit (lib) mkIf;

  base = "apophenic.net";
  mkSub = domain: "${domain}.${base}";

  smtp_server = "smtp.migadu.com";
   
  headscale_host = "ouroboros";
  headscale_domain = "${headscale_host}.${base}";
  tailnet = "interstice";
  tailnet_domain = "${tailnet}.${base}";
  headscale_addresses = {
    philae = "100.64.0.3";
    rosetta = "100.64.0.4";
    moonlight = "100.64.0.7";
  };

  kanidm_host = "gate";
  kanidm_domain = "${kanidm_host}.${base}";

  oauth2-proxy_host = "portcullis";
  oauth2-proxy_domain = "${oauth2-proxy_host}.${base}";

  vaultwarden_host = "vault";
  vaultwarden_domain = "${vaultwarden_host}.${tailnet_domain}";
  vaultwarden_email = "${vaultwarden_host}@${base}";

  forgejo_host = "git";
  forgejo_domain = mkSub forgejo_host;

  sabnzbd_host = "nz";
  sabnzbd_domain = "${sabnzbd_host}.${tailnet_domain}";

  restic_server_host = "deepfreeze";
  restic_server_domain = "${restic_server_host}.${tailnet_domain}";
in
{
  imports = [
    ./transpose.nix
  ];

  options.globals = lib.mkOption {
    description = "Global settings";
    #type = lib.types.any;
    readOnly = true;
    default = {
      acme = {
        mkChain = domain: "${config.security.acme.certs.${domain}.directory}/fullchain.pem";
        chain   = config.globals.acme.mkChain base;
        mkKey   = domain: "${config.security.acme.certs.${domain}.directory}/key.pem";
        key     = config.globals.acme.mkKey base;
      };

      domains = {
        base = base;
        mkSub = host: "${host}.${base}";
      };

      email.smtp = smtp_server;

      services = {
        nginx = rec {
          mkDefault = { listen ? null, acme_host ? base }: {
            forceSSL = true;
            useACMEHost = mkIf (acme_host != null) acme_host;
            enableACME = mkIf (acme_host == null) true;
            listenAddresses = mkIf (listen != null) listen;

            quic = true;
            http3 = true;
            # advertise quic support
            extraConfig = ''
              add_header Alt-Svc 'h3=":$server_port"; ma=86400';
            '';
          };

          mkReverseProxy = { proto ? "https", domain ? "[::1]", port, acme_host ? base, listen ? null }: (
            mkDefault { inherit acme_host listen; } // {
              locations."/" = {
                recommendedProxySettings = true;
                proxyWebsockets = true;
                proxyPass = "${proto}://${domain}:${toString port}";
              };
            }
          );
        };

        vaultwarden = {
          host = vaultwarden_host;
          domain = vaultwarden_domain;
          email = vaultwarden_email;
          url = "https://${vaultwarden_domain}";
          bindaddr = "127.0.0.1";
          bindport = 8222;
        };

        headscale = {
          host = headscale_host;
          domain = headscale_domain;

          net = {
            name = tailnet;
            domain = tailnet_domain;
          };

          bindaddr = "[::1]";
          bindport = 8081;
          addresses = headscale_addresses;

          myAddr = headscale_addresses."${config.networking.hostName}";

          mkDnsEntry = host: {
            name = "${host}.${tailnet_domain}";
            type = "A";
            value = headscale_addresses."${config.networking.hostName}";
          };

          mkSub = host: "${host}.${tailnet_domain}";
        };

        kanidm = {
          host = kanidm_host;
          domain = kanidm_domain;
          machine = "philae";
          bindaddr = "[::1]";
          bindport = 49741;
          ldapbindport = 3636;
          makeOidc = client-id: "https://${kanidm_domain}/oauth2/openid/${client-id}";
        };

        oauth2-proxy = {
          uid = 694;
          gid = 694;
          cert-group-gid = 695;
        };

        forgejo = {
          host = forgejo_host;
          domain = forgejo_domain;
          bindaddr = "::1";
          bindport = 19224;
        };

        sabnzbd = {
          host = sabnzbd_host;
          domain = sabnzbd_domain;
          bindaddr = "127.0.0.1";
          bindport = 52175;
        };

        minecraft.port = 41032;

        restic-server = {
          host = restic_server_host;
          domain = restic_server_domain;
          bindport = 33214;
        };
      };
    };
  };
}
