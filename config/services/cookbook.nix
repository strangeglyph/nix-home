{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.services.cookbook;
  acme = config.security.acme;
  cookbook-config = pkgs.writeText "config.json" (builtins.toJSON {
    COOKBOOK_LOCATION = cfg.recipe-folder;
    DEFAULT_LANG = cfg.default-language;
    SITE_NAME = cfg.site-name;
    BASE_URL = "https://${cfg.vhost}";
  });
in
{
  imports = [
    ./nginx-common.nix
  ];

  options.services.cookbook = {
    enable = mkEnableOption "cookbook service";
    vhost = mkOption { type = types.str; };
    acme-uses-dns = mkOption { type = types.bool; default = true; };
    acme-host = mkOption { 
      type = types.str; 
      description = "ACME host to use for the cert, only necessary if using DNS. Otherwise acme.http-challenge-host is used"; 
    };
    recipe-folder = mkOption { type = types.path; };
    default-language = mkOption { type = types.str; default = "en"; };
    site-name = mkOption { type = types.str; default = "Cookbook"; };
  };

  config = mkIf cfg.enable {
    security.acme.certs = mkIf (! cfg.acme-uses-dns) {
      "${ acme.http-challenge-host }".extraDomainNames = [ cfg.vhost ];
    };

    nixpkgs.overlays = [ inputs.cookbook.overlay ];

    users.groups.www-data.members = [ "nginx" "uwsgi" ];

    age.secrets."cookbook-secret.json" = {
      rekeyFile = ../../secrets/sources/cookbook-secret.json.age;
      owner = "uwsgi";
      generator.script = { pkgs, lib, ...}: ''
        key=$(${lib.getExe pkgs.openssl} rand -base64 32)
        printf '{ "SECRET_KEY": "%s" }\n'
      '';
    };

    services.nginx = {
      enable = true;
      
      virtualHosts."${cfg.vhost}" = {
        forceSSL = true;
        useACMEHost = if cfg.acme-uses-dns then cfg.acme-host else acme.http-challenge-host;

        quic = true;
        http3 = true;
        # advertise quic support
        extraConfig = ''
          add_header Alt-Svc 'h3=":$server_port"; ma=86400';
        '';

        locations."/static/".alias = "${pkgs.cookbook}/static/";
        locations."/images/" = {
          alias = "${cfg.recipe-folder}/images/";
          extraConfig = ''
            expires 7d;
            add_header Cache-Control "public";
          '';
        };
        locations."/" = {
          extraConfig = ''
            uwsgi_pass unix:${config.services.uwsgi.runDir}/cookbook.sock;
          '';
        };
      };
    };

    services.uwsgi = {
      enable = true;
      plugins = [ "python3" ];

      instance = {
        type = "emperor";
  
        vassals.cookbook = {
          type = "normal";
          master = true;
          workers = 5;
          plugin = "python3";
          chmod-socket = "664";
          chown-socket = "uwsgi:www-data";

          pythonPackages = self: [ pkgs.cookbook ];
          socket = "${config.services.uwsgi.runDir}/cookbook.sock";
          module = "cookbook:app";
          env = [
            "COOKBOOK_CONFIG=${cookbook-config}"
            "EXTRA_COOKBOOK_CONFIG=${config.age.secrets."cookbook-secret.json".path}"
          ];
        };
      };
    };
  };
}
