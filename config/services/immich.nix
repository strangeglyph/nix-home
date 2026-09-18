{
  config,
  lib,
  nodes,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  gservices = config.globals.services;
  nixpkgs-unstable = import inputs.nixpkgs-unstable { };
  cfg = config.glyph.immich;
  glib = config.glib;
in
{
  options.glyph.immich = {
    enable = lib.mkEnableOption { description = "photo manager"; };
    mediaDir = mkOption {
      description = "Location to store media files";
      default = "/data/immich";
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."immich/oidc/secret" = { };

    services.immich = {
      enable = true;
      # TODO(26.11) immich in 26.05 is EOL and declared insecure
      package = nixpkgs-unstable.immich;

      host = gservices.headscale.myAddr;
      port = gservices.immich.bindport;

      redis.enable = true;
      machine-learning.enable = true;
      database = {
        enable = true;
        createDB = true;
      };

      mediaLocation = cfg.mediaDir;

      settings = {
        backup.database = {
          cronExpression = "0 02 * * *";
          enabled = true;
          keepLastAmount = 1; # managed by restic
        };
        oauth = {
          enabled = true;
          autoLaunch = true;
          buttonText = "[ 門 ]";
          clientId = "immich";
          clientSecret._secret = config.sops.secrets."immich/oidc/secret".path;
          issuerUrl = gservices.kanidm.mkDiscoveryUrl "immich";
          roleClaim = "immich_role";
          signingAlgorithm = "ES256";
        };
        passwordLogin.enabled = false;
        server = {
          externalDomain = "https://${gservices.immich.domain}";
          publicUsers = false;
        };
      };
    };

    systemd.tmpfiles.settings."10-immich" = {
      "${cfg.mediaDir}/*".Z = {
        user = config.services.immich.user;
        group = config.services.immich.group;
        mode = "0700";
      };
    };

    # Immich automatically creates DB backups in ${cfg.mediaDir}
    #services.postgresqlBackup = {
    #  enable = true;
    #  databases = [ "immich" ];
    #  location = "/var/backups/pgsql";
    #};

    glyph.restic.immich.paths = [
      #"/var/backups/pgsql/immich.sql.qz"
      cfg.mediaDir
    ];

    glyph.transpose.nginx.virtualHosts.${gservices.immich.domain} = gservices.nginx.mkReverseProxy {
      proto = "http";
      domain = gservices.headscale.myAddr;
      port = gservices.immich.bindport;
      locationExtraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };

    glyph.transpose.kanidm = [
      {
        sops.secrets.kanidm_basic_secret_immich = {
          key = "immich/oidc/secret";
          owner = "kanidm";
        };
        provision.systems.oauth2.immich = {
          displayName = "Photos";
          preferShortUsername = true;
          originUrl = [
            "app.immich:///oauth-callback" # for mobile app login
            "https://${gservices.immich.domain}/auth/login"
            "https://${gservices.immich.domain}/user-settings"
          ];
          originLanding = "https://${gservices.immich.domain}";
          basicSecretFile =
            nodes."${gservices.kanidm.machine}".config.sops.secrets.kanidm_basic_secret_immich.path;
          scopeMaps."immich_users" = [
            "openid"
            "profile"
            "email"
          ];
          scopeMaps."immich_admins" = [
            "openid"
            "profile"
            "email"
          ];
          claimMaps = {
            immich_role = {
              joinType = "ssv"; # Immich wants singleton value
              valuesByGroup = {
                "immich_users" = [ "user" ];
                "immich_admins" = [ "admin" ];
              };
            };
          };
          imageFile = glib.flakeRootPath "assets/immich-logo.png";
        };
      }
    ];
  };
}
