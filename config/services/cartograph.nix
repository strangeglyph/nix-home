{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.services.cartograph;
  acme = config.security.acme;
  state-dir = "/var/lib/${cfg.state-dir-name}";
  cartograph-config = pkgs.writeText "config.json" (builtins.toJSON {
    PHOTO_LOCATION = "${state-dir}/photos/";
    SITE_NAME = cfg.site-name;
    BASE_URL = "https://${cfg.vhost}";
    DB_LOCATION = "${state-dir}/cartograph.sqlite";
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
    security.acme.certs."${ acme.http-challenge-host }".extraDomainNames = [ cfg.vhost ];

    users.groups.www-data.members = [ "nginx" "uwsgi" ];

    nixpkgs.overlays = [ inputs.cartograph.overlay ];

    age.secrets."cartograph.env" = {
      rekeyFile = ../../secrets/sources/cartograph.env.age;
      owner = "uwsgi";
    };

    services.nginx = {
      enable = true;
      
      virtualHosts."${cfg.vhost}" = {
        forceSSL = true;
        useACMEHost = acme.http-challenge-host;
        locations."/static/".alias = "${pkgs.cartograph}/static/";
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

          pythonPackages = self: [ pkgs.cartograph ];
          socket = "${config.services.uwsgi.runDir}/cartograph.sock";
          module = "cartograph:app";
          env = [
            "CARTOGRAPH_CONFIG=${cartograph-config}"
            "EXTRA_CARTOGRAPH_CONFIG=${config.age.secrets."cartograph.env".path}"
          ];
        };
      };
    };
    
    systemd.services.uwsgi.serviceConfig.StateDirectory = [cfg.state-dir-name];
  };
}
