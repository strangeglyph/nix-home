{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.cartograph;
  acme = config.security.acme;
  repo = pkgs.fetchFromGitHub {
    owner = "strangeglyph";
    repo = "cartograph";
    rev = "main";
    hash = "sha256-bQPwh9AyVNGPoSHBSOQlJa3+k6g05OHOde6BWuFRLUY=";
  };
  cartograph = pkgs.python3Packages.callPackage "${ repo }/derivation.nix" {};
  state-dir = "/var/lib/${cfg.state-dir-name}";
  secrets = import ../secrets/cartograph.nix {};
  cartograph-config = pkgs.writeText "config.json" (builtins.toJSON {
    SECRET_KEY = secrets.session-key;
    PHOTO_LOCATION = "${state-dir}/photos/";
    SITE_NAME = cfg.site-name;
    BASE_URL = "https://${cfg.vhost}";
    GEODATA_MAIL_HOST = secrets.mail.host;
    GEODATA_MAIL_USER = secrets.mail.user;
    GEODATA_MAIL_PASSWORD = secrets.mail.password;
    DB_LOCATION = "${state-dir}/cartograph.sqlite";
    WEBDAV_URL = secrets.webdav.url;
    WEBDAV_LOGIN = secrets.webdav.login;
    WEBDAV_PASSWORD = secrets.webdav.password;
    WEBDAV_FILE_PATH = "Bilder PCT";
  });
in
{
  imports = [
    ./nginx-common.nix
  ];

  options.services.cartograph = {
    enable = mkEnableOption "cartograph service";
    vhost = mkOption { type = types.str; };
    site-name = mkOption { type = types.str; default = "Cartograph"; };
    state-dir-name = mkOption { type = types.str; default = "cartograph"; };
  };

  config = mkIf cfg.enable {
    security.acme.certs."${ acme.challenge-host }".extraDomainNames = [ cfg.vhost ];

    users.groups.www-data.members = [ "nginx" "uwsgi" ];

    services.nginx = {
      enable = true;
      
      virtualHosts."${cfg.vhost}" = {
        forceSSL = true;
        useACMEHost = acme.challenge-host;
        locations."/static/".alias = "${cartograph}/static/";
        locations."/static/photos/" = {
          alias = "${state-dir}/photos/";
          extraConfig = ''
            expires 7d;
            add_header Cache-Control "public";
          '';
        };
        locations."/" = {
          extraConfig = ''
            uwsgi_pass unix:${config.services.uwsgi.runDir}/cartograph.sock;
          '';
        };
      };
    };

    services.uwsgi = {
      enable = true;
      plugins = [ "python3" ];

      instance = {
        type = "emperor";
  
        vassals.cartograph = {
          type = "normal";
          master = true;
          workers = 5;
          plugin = "python3";
          chmod-socket = "664";
          chown-socket = "uwsgi:www-data";
          enable-threads = true;

          pythonPackages = self: with self; [ cartograph ];
          socket = "${config.services.uwsgi.runDir}/cartograph.sock";
          module = "cartograph:app";
          env = ["CARTOGRAPH_CONFIG=${cartograph-config}"];
        };
      };
    };
    
    systemd.services.uwsgi.serviceConfig.StateDirectory = [cfg.state-dir-name];
  };
}
