{
  lib,
  nodes,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glyph.monitoring.grafana;
  gservices = config.globals.services;
  glib = config.glib;
in
{
  options.glyph.monitoring.grafana.enable = mkEnableOption "grafana metrics dashboard";

  config = mkIf cfg.enable {
    sops.secrets."grafana/secret" = {
      owner = "grafana";
    };
    sops.secrets."grafana/oidc/secret" = {
      owner = "grafana";
    };

    services.grafana = {
      enable = true;

      settings = {
        server = {
          domain = gservices.grafana.domain;
          root_url = "https://${gservices.grafana.domain}";
          http_addr = gservices.grafana.bindaddr;
          http_port = gservices.grafana.bindport;
        };
        analytics = {
          reporting_enabled = false;
          check_for_updates = false;
          check_for_plugin_updates = false;
        };
        security = {
          disable_initial_admin_creation = true;
          disable_gravatar = true;
          secret_key = "$__file{${config.sops.secrets."grafana/secret".path}}";
        };
        auth = {
          disable_login_form = true;
        };
        "auth.generic_oauth" = {
          enabled = true;
          auto_login = true;
          name = "Gate";
          client_id = "grafana";
          client_secret = "$__file{${config.sops.secrets."grafana/oidc/secret".path}}";
          scopes = "openid email profile";
          auth_url = "https://${gservices.kanidm.domain}/ui/oauth2";
          token_url = "https://${gservices.kanidm.domain}/oauth2/token";
          api_url = "https://${gservices.kanidm.domain}/oauth2/openid/grafana/userinfo";
          use_pkce = true;
          use_refresh_token = true;
          validate_id_token = true;
          jwk_set_url = "https://${gservices.kanidm.domain}/oauth2/openid/grafana/public_key.jwk";
          allow_sign_up = true;
          allow_assign_grafana_admin = true;
          login_attribute_path = "preferred_username";
          name_attribute_path = "preferred_username";
          role_attribute_path = "contains(grafana_role[*], 'GrafanaAdmin') && 'GrafanaAdmin' || 'Viewer'";
        };
      };

      provision = {
        enable = true;

        datasources.settings = {
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://${gservices.prometheus.domain}:${toString gservices.prometheus.bindport}";
              isDefault = true;
              editable = false;
            }
          ];
        };
      };
    };

    security.acme.certs."${gservices.grafana.domain}" = {
      reloadServices = [ "nginx.service" ];
      group = "nginx";
    };

    glyph.transpose.headscale.dns = [
      (gservices.headscale.mkDnsEntry gservices.grafana.host)
    ];

    services.nginx = {
      virtualHosts."${gservices.grafana.domain}" = gservices.nginx.mkReverseProxy {
        proto = "http";
        domain = "${gservices.grafana.bindaddr}";
        port = gservices.grafana.bindport;
        listen = [ gservices.headscale.myAddr ];
        acme_host = gservices.grafana.domain;
      };
    };

    glyph.transpose.kanidm = [
      {
        sops.secrets.kanidm_basic_secret_grafana = {
          key = "grafana/oidc/secret";
          owner = "kanidm";
        };
        provision.persons.glyph.groups = [
          "grafana_admins"
          "grafana_users"
        ];
        provision.groups = {
          grafana_admins = { };
          grafana_users = { };
        };
        provision.systems.oauth2.grafana = {
          displayName = "Grafana";
          preferShortUsername = true;
          originUrl = [
            "https://${gservices.grafana.domain}/login/generic_oauth"
          ];
          originLanding = "https://${gservices.grafana.domain}";
          basicSecretFile =
            nodes."${gservices.kanidm.machine}".config.sops.secrets.kanidm_basic_secret_grafana.path;
          scopeMaps."grafana_users" = [
            "openid"
            "profile"
            "email"
          ];
          claimMaps = {
            grafana_role = {
              joinType = "array";
              valuesByGroup = {
                "grafana_users" = [ ];
                "grafana_admins" = [ "GrafanaAdmin" ];
              };
            };
          };
          imageFile = glib.flakeRootPath "assets/grafana-logo.svg";
        };
      }
    ];
  };
}
