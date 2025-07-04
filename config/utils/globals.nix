{ lib, config, ... }:
let 
  inherit (lib) mkIf;

  base = "apophenic.net"; 

  smtp_server = "smtp.migadu.com";
   
  headscale_host = "ouroboros";
  headscale_domain = "${headscale_host}.${base}";
  tailnet = "interstice";
  tailnet_domain = "${tailnet}.${base}";
  headscale_addresses = {
    philae = "100.64.0.3";
    rosetta = "100.64.0.4";
  };

  kanidm_host = "gate";
  kanidm_domain = "${kanidm_host}.${base}";

  oauth2-proxy_host = "portcullis";
  oauth2-proxy_domain = "${oauth2-proxy_host}.${base}";

  vaultwarden_host = "vault";
  vaultwarden_domain = "${vaultwarden_host}.${tailnet_domain}";
  vaultwarden_email = "${vaultwarden_host}@${base}";

  sabnzbd_host = "nz";
  sabnzbd_domain = "${sabnzbd_host}.${tailnet_domain}";
in
{
  acmeChainPath = "${config.security.acme.certs.${base}.directory}/fullchain.pem";
  acmeKeyPath   = "${config.security.acme.certs.${base}.directory}/key.pem";
  mkHeadscaleDnsEntry = host: {
    name = "${host}.${tailnet_domain}";
    type = "A";
    value = headscale_addresses."${config.networking.hostName}";
  };

  mkNginxReverseProxy = { proto ? "https", domain ? "[::1]", port, acme_host ? base, listen ? null }: {
    forceSSL = true;
    useACMEHost = acme_host;
    listenAddresses = mkIf (listen != null) listen;

    quic = true;
    http3 = true;
    # advertise quic support
    extraConfig = ''
      add_header Alt-Svc 'h3=":$server_port"; ma=86400';
    '';

    locations."/" = {
      recommendedProxySettings = true;
      proxyWebsockets = true;
      proxyPass = "${proto}://${domain}:${toString port}";
    };
  };

  domains = {
    inherit base;
  };
  email = {
    smtp = smtp_server;
  };
  services = {
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
    };

    kanidm = {
      host = kanidm_host;
      domain = kanidm_domain;
      makeOidc = client-id: "https://${kanidm_domain}/oauth2/openid/${client-id}";
    };

    catamedian = {
      sabnzbd = {
        host = sabnzbd_host;
        domain = sabnzbd_domain;
        bindaddr = "127.0.0.1";
        bindport = 52175;
      };
    };
  };
}
