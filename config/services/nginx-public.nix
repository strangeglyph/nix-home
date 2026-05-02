{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glyph.nginx-public;
  globals = config.globals;
in
{
  options.glyph.nginx-public = {
    enable = mkEnableOption "Public-facing nginx reverse proxy";
  };

  config = mkIf cfg.enable {
    security.acme = {
      http-challenge-host = "acme.strangegly.ph";
      certs."acme.strangegly.ph" = {
        extraDomainNames = [ "cookbook.strangegly.ph" ];
      };
    };

    nginx.virtualHosts = {
      "cookbook.strangegly.ph" = {
        forceSSL = true;
        useACMEHost = config.security.acme.http-challenge-host;
        globalRedirect = "cookbook.${globals.domains.base}";
      };
      "wo-ist-ole.strangegly.ph" = {
        forceSSL = true;
        useACMEHost = config.security.acme.http-challenge-host;
        globalRedirect = "wo-ist-ole.${globals.domains.base}";
      };
      "cloud.strangegly.ph" = {
        forceSSL = true;
        useACMEHost = config.security.acme.http-challenge-host;
        globalRedirect = "cloud.${globals.domains.base}";
      };
      "~^(.*\.)?${config.globals.services.headscale.net.domain}$" = {
        forceSSL = true;
        useACMEHost = config.globals.domains.base;
        locations."/(.*)".return = "200 '${builtins.readFile ../assets/interstice-landing.html}'";
      };
    }
    // lib.mkMerge (
      config.glyph.transpose-here [
        "nginx"
        "virtualHosts"
      ]
    );
  };
}
