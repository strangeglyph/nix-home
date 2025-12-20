{ config, lib, nodes, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  gservices = config.globals.services;
  sso_config = { 
    PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
      openid_connect = {
        OAUTH_PKCE_ENABLED = true;
        APPS = [{
          provider_id = "kanidm";
          name = "門";
          client_id = "paperless";
          settings = {
            fetch_userinfo = true;
            server_url = "https://${gservices.kanidm.domain}/oauth2/openid/paperless";
          };
        }];
      };
    };
  };
in
{
  imports = [
    ./restic-backup.nix
  ];

  options = {
    glyph.paperless.enable = mkEnableOption { description = "glyph paperless settings"; };
  };

  config = mkIf config.glyph.paperless.enable {
    age.secrets = {
      paperless-env = {
        rekeyFile = ../../secrets/sources/paperless/env.age;
        generator = {
          dependencies.basic_secret = nodes."${gservices.kanidm.machine}".config.age.secrets.kanidm_basic_secret_paperless;
          script = { pkgs, deps, decrypt, ... }: ''
            set -euo pipefail
            ${lib.toShellVars sso_config}
            basic_secret="$(${decrypt} ${lib.escapeShellArg deps.basic_secret.file})"
            
            echo -n PAPERLESS_SOCIALACCOUNT_PROVIDERS=
            read -r replaced <<< $(echo $PAPERLESS_SOCIALACCOUNT_PROVIDERS | jq -c ".openid_connect.APPS.[0].secret = \"$basic_secret\"")
            printf %q $replaced
          '';
        };
      };
      paperless-admin-pass = {
        rekeyFile = ../../secrets/sources/paperless/admin-pass.age;
        generator.script = "alnum";
      };
    };

    glyph.transpose.kanidm = [{
      age.secrets."kanidm_basic_secret_paperless" = {
        rekeyFile = ../../secrets/sources/kanidm/basic_secret_paperless.age;
        owner = "kanidm";
        generator.script = "alnum";
      };
      provision.systems.oauth2."paperless" = {
        displayName = "Paper/Less";
        preferShortUsername = true;
        originUrl = "https://${gservices.paperless.domain}/accounts/oidc/kanidm/login/callback/";
        originLanding = "https://${gservices.paperless.domain}";
        basicSecretFile = nodes."${gservices.kanidm.machine}".config.age.secrets."kanidm_basic_secret_paperless".path;
        scopeMaps."paperless_users" = [ "openid" "profile" "email" "groups" ];
        imageFile = ../../assets/paperless-logo.svg;
      };
    }];

    services.paperless = {
      enable = true;
      domain = gservices.paperless.domain;
      environmentFile = config.age.secrets.paperless-env.path;
      passwordFile = config.age.secrets.paperless-admin-pass.path;
      port = gservices.paperless.bindport;
      address = gservices.paperless.bindaddr;
      configureNginx = true;
      configureTika = true;

      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
        PAPERLESS_ENABLE_COMPRESSION = false;

        PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = false;
        PAPERLESS_DISABLE_REGULAR_LOGIN = true;
        PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
        PAPERLESS_SOCIAL_AUTO_SIGNUP = true;

        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
      };

      exporter = {
        enable = true;
        directory = "/var/backups/paperless";
        settings = {
          no-color = true;
          no-progress-bar = true;
          delete = true;
        };
      };
    };

    ## most of the relevant options are already set by paperless.configureNginx
    services.nginx.virtualHosts."${gservices.paperless.domain}" = {
      enableACME = true;

      quic = true;
      http3 = true;
      # advertise quic support
      extraConfig = ''
        add_header Alt-Svc 'h3=":$server_port"; ma=86400';
      '';
    };

    systemd.tmpfiles.settings."10-paperless"."/var/backups/paperless".d = {
      user = "paperless";
      group = "paperless";
      mode = "0700";
    };

    glyph.restic."paperless".paths = [
      "/var/backups/paperless"
    ];
  };
}