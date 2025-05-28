{ ... }:
let 
  base = "apophenic.net"; 

  smtp_server = "smtp.migadu.com";
   
  headscale_host = "ouroboros";
  headscale_domain = "${headscale_host}.${base}";
  tailnet = "interstice";
  tailnet_domain = "${tailnet}.${base}";

  kanidm_host = "gate";
  kanidm_domain = "${kanidm_host}.${base}";

  vaultwarden_host = "vault";
  vaultwarden_domain = "${vaultwarden_host}.${tailnet_domain}";
  vaultwarden_email = "${vaultwarden_host}@${base}";
in
{
  mkAcmeChainPath = config: "${config.security.acme.certs.${base}.directory}/fullchain.pem";
  mkAcmeKeyPath   = config: "${config.security.acme.certs.${base}.directory}/key.pem";

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
      addresses = {
        philae = "100.64.0.3";
      };
    };

    kanidm = {
      host = kanidm_host;
      domain = kanidm_domain;
      makeOidc = client-id: "https://${kanidm_domain}/oauth2/openid/${client-id}";
    };
  };
}
