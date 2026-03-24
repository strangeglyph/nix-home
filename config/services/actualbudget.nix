{
  config,
  pkgs,
  lib,
  nodes,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  gservices = config.globals.services;
in
{
  options.glyph.actualbudget.enable = mkEnableOption { description = "ActualBudget"; };

  config = mkIf config.glyph.actualbudget.enable {

    security.acme.certs."${gservices.actualbudget.domain}" = {
      reloadServices = [ "nginx.service" ];
      group = "nginx";
    };

    sops.secrets."actualbudget/oidc/secret" = { };
    sops.templates."actualbudget.env".content = ''
      ACTUAL_OPENID_CLIENT_SECRET=${config.sops.placeholder."actualbudget/oidc/secret"}
    '';

    systemd.services.actual.serviceConfig.EnvironmentFile = [
      config.sops.templates."actualbudget.env".path
    ];

    services.actual = {
      enable = true;
      settings = {
        hostname = gservices.actualbudget.bindaddr;
        port = gservices.actualbudget.bindport;
        loginMethod = "openid";
        allowedLoginMethods = [ "openid" ];

        openId = {
          discoveryURL = "${gservices.kanidm.mkDiscoveryUrl "actualbudget"}/.well-known/openid-configuration";
          client_id = "actualbudget";
          server_hostname = "https://${gservices.actualbudget.domain}";
          authMethod = "openid";
        };
      };
    };

    services.nginx.virtualHosts."${gservices.actualbudget.domain}" = gservices.nginx.mkReverseProxy {
      proto = "http";
      domain = "[${gservices.actualbudget.bindaddr}]";
      port = gservices.actualbudget.bindport;
      acme_host = gservices.actualbudget.domain;
      listen = [ gservices.headscale.myAddr ];

      locationExtraConfig = ''
        proxy_hide_header Cross-Origin-Embedder-Policy;
        proxy_hide_header Cross-Origin-Opener-Policy;

        add_header Cross-Origin-Embedder-Policy "require-corp" always;
        add_header Cross-Origin-Opener-Policy "same-origin" always;
        add_header Origin-Agent-Cluster "?1" always;
      '';
    };

    glyph.transpose.headscale.dns = [
      (gservices.headscale.mkDnsEntry gservices.actualbudget.host)
    ];

    glyph.transpose.kanidm = [
      {
        sops.secrets.kanidm_basic_secret_actualbudget = {
          key = "actualbudget/oidc/secret";
          owner = "kanidm";
        };
        provision.systems.oauth2.actualbudget = {
          displayName = "ActualBudget";
          preferShortUsername = true;
          originUrl = "https://${gservices.actualbudget.domain}/openid/callback";
          originLanding = "https://${gservices.actualbudget.domain}";
          basicSecretFile =
            nodes."${gservices.kanidm.machine}".config.sops.secrets.kanidm_basic_secret_actualbudget.path;
          scopeMaps."actualbudget_users" = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          imageFile = ../../assets/actualbudget-logo.svg;
        };
      }
    ];
  };
}
