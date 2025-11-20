all@{ config, lib, ... }:
let
  cfg = config.services.vaultwarden;
  globals_vw = config.globals.services.vaultwarden;
in
{
  imports = [ 
    ./nginx-common.nix
    ./restic-backup.nix
  ];

  options.glyph.vaultwarden.enable = lib.mkEnableOption {};

  config = lib.mkIf config.glyph.vaultwarden.enable {
    age.secrets.vaultwarden_env = {
      rekeyFile = ../../secrets/sources/vaultwarden_env.age;
    };

    services.vaultwarden = {
      enable = true;

      environmentFile = config.age.secrets.vaultwarden_env.path;
      backupDir = "/var/backups/vaultwarden";

      config = {
        DOMAIN = globals_vw.url;
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = globals_vw.bindaddr;
        ROCKET_PORT = globals_vw.bindport;
        ROCKET_LOG = "critical";
        SMTP_HOST = config.globals.email.smtp;
        SMTP_FROM = globals_vw.email;
        SMTP_FROM_NAME = "Vault";
        SMTP_USERNAME = globals_vw.email;
        SMTP_SECURITY = "force_tls";
        PUSH_ENABLED = true;
        PUSH_RELAY_URI = "https://api.bitwarden.eu";
        PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
      };
    };

    services.headscale.settings.dns.extra_records = [{
      name = globals_vw.domain;
      type = "A";
      value = config.globals.services.headscale.addresses."${config.networking.hostName}";
    }];

    services.nginx = {
      enable = true;
      virtualHosts."${globals_vw.domain}" = {
        forceSSL = true;
        listenAddresses = [
          config.globals.services.headscale.addresses."${config.networking.hostName}"
        ];
        useACMEHost = config.globals.domains.base;

        quic = true;
        http3 = true;
        # advertise quic support
        extraConfig = ''
          add_header Alt-Svc 'h3=":$server_port"; ma=86400';
        '';

        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://${globals_vw.bindaddr}:${toString globals_vw.bindport}";
        };
      };
    };

    glyph.restic.vaultwarden = {
      paths = [ "/var/backups/vaultwarden" ];
    };
  };
}
