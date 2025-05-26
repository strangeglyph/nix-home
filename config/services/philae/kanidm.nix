{ config, pkgs, ... }:
let
  kanidm = config.services.kanidm;
  glyphscale = config.services.glyphscale;
in
{
  config.services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning;
    host = "gate";
    base-domain = "apophenic.net";
    provision = {
      enable = false;
      #acceptInvalidCerts = true;
      # instanceUrl = kanidm.serverSettings.origin;

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
          originUrl = "https://${glyphscale.headscale-name}.${glyphscale.base-domain}/oidc/callback";
          originLanding = "https://${glyphscale.headscale-name}.${glyphscale.base-domain}/";
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
