{ config, pkgs, lib, nodes, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  glyph = config.glyph;
  globals = config.globals;
  inherit (globals.services.kanidm) makeOidc;
  kanidm_host = globals.services.kanidm.machine;
  g_forgejo = globals.services.forgejo;
  cfg = config.services.forgejo;
in
{
  options.glyph.forgejo.enable = mkEnableOption { description = "git server"; };

  config = mkIf glyph.forgejo.enable {
    age.secrets.forgejo_mailer_addr.rekeyFile = ../../secrets/sources/forgejo/mailer/addr.age;
    age.secrets.forgejo_mailer_user.rekeyFile = ../../secrets/sources/forgejo/mailer/user.age;
    age.secrets.forgejo_mailer_pass.rekeyFile = ../../secrets/sources/forgejo/mailer/pass.age;
    age.secrets."kanidm_basic_secret_forgejo_side" = {
      rekeyFile = ../../secrets/sources/kanidm/basic_secret_forgejo.age;
      owner = "forgejo";
      generator.script = "alnum";
    };

    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      lfs.enable = true;

      settings = {
        DEFAULT.APP_NAME = "Foundry";
        DEFAULT.APP_SLOGAN = "/bitcarding/";

        server = {
          DOMAIN = g_forgejo.domain;
          ROOT_URL = "https://${g_forgejo.domain}";
          PROTOCOL = "https";
          CERT_FILE = "/run/credentials/forgejo.service/cert.pem";
          KEY_FILE = "/run/credentials/forgejo.service/key.pem";
          HTTP_PORT = g_forgejo.bindport;
          HTTP_ADDR = g_forgejo.bindaddr;
        };

        session.COOKIE_SECURE = true;

        # Other settings kept secret, see below
        mailer = {
          ENABLED = true;
          SMTP_PORT = 465;
        };

        # Recommended from... somewhere
        cache = {
          ADAPTER = "twoqueue";
          HOST = builtins.toJSON {
            size = 100;
            recent_ratio = 0.25;
            ghost_ratio = 0.5;
          };
        };

        security = {
          LOGIN_REMEMBER_DAYS = 180;
        };

        openid = {
          ENABLE_OPENID_SIGNIN = false;
          ENABLE_OPENID_SIGNUP = true;
          WHITELISTED_URIS = globals.services.kanidm.domain;
        };

        oauth2_client = {
          OPENID_CONNECT_SCOPES = "profile email groups";
          ENABLE_AUTO_REGISTRATION = true;
          USERNAME = "nickname";
        };

        service = {
          DISABLE_REGISTRATION = false;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
          DEFAULT_KEEP_EMAIL_PRIVATE = true;
        };
      };
      secrets = {
        mailer = {
          SMTP_ADDR = config.age.secrets.forgejo_mailer_addr.path;
          FROM = config.age.secrets.forgejo_mailer_user.path;
          USER = config.age.secrets.forgejo_mailer_user.path;
          PASSWD = config.age.secrets.forgejo_mailer_pass.path;
        };
      };
      dump = {
        enable = true;
        interval = "hourly";
        backupDir = "/var/backups/forgejo";
        file = "forgejo_dump";
      };
    };

    services.nginx.virtualHosts."${g_forgejo.domain}" = globals.services.nginx.mkReverseProxy {
      port = g_forgejo.bindport;
      acme_host = null;
    };

    systemd.services.forgejo.serviceConfig.LoadCredential = [
      "cert.pem:${globals.acme.mkChain g_forgejo.domain}"
      "key.pem:${globals.acme.mkKey g_forgejo.domain}"
    ];

    systemd.services.forgejo-oidc-provision = {
      enable = true;
      description = "Ensure kanidm as Forgejo OIDC provider";
      wantedBy = [ "forgejo.service" ];
      after = [ "forgejo.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = "forgejo";
        ExecStart = let 
          forgejoCmd = "${lib.getExe cfg.package} --config ${cfg.customDir}/conf/app.ini";
          awk = lib.getExe pkgs.gawk;
        in 
          pkgs.writeShellScript "forgejo-oidc-provision" ''
            set -euo pipefail
            BASIC_SECRET=$(cat ${config.age.secrets."kanidm_basic_secret_forgejo_side".path})
            FORGEJO_SUBCOMMAND=add-oauth

            if (${forgejoCmd} admin auth list | ${awk} 'BEGIN{c=1}$2=="kanidm"{c=0}END{exit c}'); then
              AUTH_SOURCE_ID=$(${forgejoCmd} admin auth list | ${awk} '$2=="kanidm"{print $1}')
              echo "Auth source 'kanidm' already exists (with id $AUTH_SOURCE_ID)"
              FORGEJO_SUBCOMMAND="update-oauth --id $AUTH_SOURCE_ID"
            fi

            ${forgejoCmd} admin auth $FORGEJO_SUBCOMMAND \
              --name "kanidm" \
              --provider "openidConnect" \
              --key "forgejo" \
              --secret "$BASIC_SECRET" \
              --auto-discover-url "${makeOidc "forgejo"}/.well-known/openid-configuration" \
              --skip-local-2fa true \
              --group-claim-name "groups" \
              --admin-group "forgejo_admins@${globals.services.kanidm.domain}"
          '';
      };
    };

    glyph.transpose.kanidm = [{
      age.secrets."kanidm_basic_secret_forgejo" = {
        rekeyFile = ../../secrets/sources/kanidm/basic_secret_forgejo.age;
        owner = "kanidm";
        generator.script = "alnum";
      };
      provision.systems.oauth2."forgejo" = {
        displayName = "${cfg.settings.DEFAULT.APP_NAME}";
        preferShortUsername = true;
        originUrl = "https://${g_forgejo.domain}/user/oauth2/kanidm/callback";
        originLanding = "https://${g_forgejo.domain}";
        basicSecretFile = nodes."${kanidm_host}".config.age.secrets."kanidm_basic_secret_forgejo".path;
        scopeMaps."forgejo_users" = [ "openid" "profile" "email" "groups" ];
      };
    }];

    glyph.restic.forgejo.paths = [ "/var/backups/forgejo" ];
  };
}
