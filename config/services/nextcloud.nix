{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.nextcloud;
  acme = config.security.acme;
  further-cfg = config.services.nextcloud-personal;
in
{
  imports = [
    ./nginx-common.nix
  ];

  options.glyph.nextcloud.enable = mkEnableOption { };

  config = mkIf config.glyph.nextcloud.enable {

    sops.secrets."nextcloud/mail/mailbox" = { };
    sops.secrets."nextcloud/mail/domain" = { };
    sops.secrets."nextcloud/mail/pass" = { };
    sops.templates."nextcloud/mail/login".content = "${
      config.sops.placeholder."nextcloud/mail/mailbox"
    }@${config.sops.placeholder."nextcloud/mail/domain"}";
    # https://github.com/NixOS/nixpkgs/issues/487286
    sops.templates."nextcloud/secrets".content = builtins.toJSON {
      mail_from_address = config.sops.placeholder."nextcloud/mail/mailbox";
      mail_domain = config.sops.placeholder."nextcloud/mail/domain";
      mail_smtpname = "${config.sops.placeholder."nextcloud/mail/mailbox"}@${
        config.sops.placeholder."nextcloud/mail/domain"
      }";
      mail_smtppassword = config.sops.placeholder."nextcloud/mail/pass";
    };

    services.nextcloud = {
      enable = true;
      https = true;
      autoUpdateApps.enable = true;
      autoUpdateApps.startAt = "05:00:00";

      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        dbpassFile = "/var/nextcloud/db-pass";

        adminuser = "glyph";
        adminpassFile = "/var/nextcloud/admin-pass";
      };

      settings = {
        default_phone_region = "de";
        maintenance_window_start = 2;
        mail_smtpsecure = "ssl";
        mail_smtpport = 465;
        mail_smtphost = "smtp.migadu.com";
        mail_smtpauth = true;
      };

      phpOptions = {
        "opcache.interned_strings_buffer" = "32";
      };

      secrets = {
        mail_from_address = config.sops.secrets."nextcloud/mail/mailbox".path;
        mail_domain = config.sops.secrets."nextcloud/mail/domain".path;
        mail_smtpname = config.sops.templates."nextcloud/mail/login".path;
        mail_smtppassword = config.sops.secrets."nextcloud/mail/pass".path;
      };

      secretFile = config.sops.templates."nextcloud/secrets".path;
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    services.postgresqlBackup = {
      enable = true;
      databases = [ "nextcloud" ];
      location = "/var/backups/pgsql";
    };

    services.nginx = {
      enable = true;

      virtualHosts."${cfg.hostName}" = {
        forceSSL = true;
        enableACME = true;
      };
    };

    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };

    glyph.restic.nextcloud.paths = [
      "/var/backups/pgsql/nextcloud.sql.qz"
      "/var/lib/nextcloud"
    ];
  };
}
