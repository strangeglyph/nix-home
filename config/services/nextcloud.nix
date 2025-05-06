{ config, pkgs, lib, ... }:
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


  config = mkIf cfg.enable {
    security.acme.certs."${ acme.http-challenge-host }".extraDomainNames = [ cfg.hostName ];

    services.nextcloud = {
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
      };
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

    services.nginx = {
      enable = true;

      virtualHosts."${cfg.hostName}" = {
        forceSSL = true;
        useACMEHost = acme.http-challenge-host;
      };
    };

    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
