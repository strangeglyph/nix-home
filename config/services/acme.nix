{ config, ... }:
{
  age.secrets = {
    cloudflare_api.rekeyFile = ../../secrets/sources/cloudflare_api.env.age;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@admin.apophenic.net";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cloudflare_api.path;
      dnsResolver = "9.9.9.9";
    };
  };
}