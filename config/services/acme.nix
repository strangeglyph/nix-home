{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf types;
  inherit (config) globals;
in
{
  options.glyph.acme = {
    enable = mkOption {
      description = "Enable acme DNS challenges";
      default = true;
      type = types.bool;
    };
  };

  config = mkIf config.glyph.acme.enable {
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
      certs."${globals.domains.base}" = {
        domain = "*.${globals.domains.base}";
        extraDomainNames = [ "*.${globals.services.headscale.net.domain}" ];
        group = "acme";
      };
    };
  };
}
