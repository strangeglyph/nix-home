{ config, pkgs, lib, ... }:

{
  services.nextcloud = {
    enable = true;
    hostName = undefined;
    nginx.enable = true;
    https = true;
    autoUpdateApps.enable = true;
 fs
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbPassFile = undefined;
      adminpassFile = undefined;
      adminuser = root;
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."${config.services.nextcloud.hostName}" = {
      forceSSL = true;
      enableAcme = true;
    }
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
}
