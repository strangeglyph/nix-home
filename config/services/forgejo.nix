{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  glyph = config.glyph;
  globals = config.globals;
  g_forgejo = globals.services.forgejo;
  cfg = config.services.forgejo;
in
{
  options.glyph.forgejo.enable = mkEnableOption { description = "git server"; };

  config = mkIf glyph.forgejo.enable {
    age.secrets.forgejo_mailer_addr.rekeyFile = ../agenix/forgejo/mailer/addr.age;
    age.secrets.forgejo_mailer_user.rekeyFile = ../agenix/forgejo/mailer/user.age;
    age.secrets.forgejo_mailer_pass.rekeyFile = ../agenix/forgejo/mailer/pass.age;

    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      settings = {
        DEFAULT.APP_NAME = "Foundry";

        server = {
          DOMAIN = g_forgejo.domain;
          ROOT_URL = "https://${g_forgejo.domain}";
          PROTOCOL = "http";
          HTTP_PORT = g_forgejo.bindport;
          HTTP_ADDR = g_forgejo.bindaddr;
        };

        session.COOKIE_SECURE = true;

        mailer = {
          ENABLED = true;
          PORT = 465;
        };

        cache = {
          ADAPTER = "twoqueue";
          HOST = builtins.toJson {
            size = 100;
            recent_ratio = 0.25;
            ghost_ratio = 0.5;
          };
        };

        security = {
          LOGIN_REMEMBER_DAYS = 180;
        };

        oauth2_client = {
          OPENID_CONNECT_SCOPES = [ "email" "access" ];
          ENABLE_AUTO_REGISTRATION = true;
          USERNAME = "nickname";
        };

        service = {
          DISABLE_REGISTRATION = true;
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
    };

    services.nginx.virtualHosts."${g_forgejo.domain}" = globals.services.nginx.makeReverseProxy {
      proto = "http";
      port = g_forgejo.bindport;
    };

    glyph.kanidm.crossProvision = 
  };
}
