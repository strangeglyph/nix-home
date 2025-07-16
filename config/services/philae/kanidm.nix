{ config, pkgs, globals, ... }:
let
  kanidm = config.services.kanidm;
  globals_hs = config.globals.services.headscale;
in
{
  config.services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning;
    provision = {
      enable = false;
      #acceptInvalidCerts = true;
      # instanceUrl = kanidm.serverSettings.origin;
      # instanceUrl = "https://${g_kanidm.bindaddr}.${toString g_kanidm.bindport}";

      persons = {
        "glyph" = {
          displayName = "glyph";
          mailAddresses = [ "mail@apophenic.net" ];
          groups = [
            "interstice_users"
          ];
        };
      };
      groups = {
        "interstice_users" = {};
      };
      systems.oauth2 = {
        "interstice" = {
          displayName = "Interstice";
          originUrl = "https://${globals_hs.domain}/oidc/callback";
          originLanding = "https://${globals_hs.domain}/";
          basicSecretFile = config.age.secrets.kanidm_oauth_interstice.path;
          preferShortUsername = true;
          scopeMaps."interstice_users" = [
            "openid"
            "email"
            "profile"
          ];
        };
      };
    };
  };
}
