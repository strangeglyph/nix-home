{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.cookbook;
  acme = config.security.acme;
  cookbook-repo = pkgs.fetchFromGitHub {
    owner = "strangeglyph";
    repo = "cookbook";
    rev = "master";
    hash = "sha256-dlsq2wzf5mvZyqgbliUUpxkvu0FnjMZzpOZLGBuoTHY=";
  };
  cookbook = pkgs.python3Packages.callPackage "${ cookbook-repo }/derivation.nix" {};
  cookbook-recipes = pkgs.fetchFromGitHub {
    owner = "strangeglyph";
    repo = "cookbook-recipes";
    rev = "master";
    sha256 = "sha256-Zg5vrj0xMYXev94c9FSk1Kx3yCYz8d0X78bAG05PxCg=";
  };
  cookbook-config = pkgs.writeText "config.json" (builtins.toJSON {
    SECRET_KEY = builtins.readFile ../secrets/cookbook-session-key;
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
    recipe-folder = mkOption { type = types.str; default = "${ cookbook-recipes }"; };
    default-language = mkOption { type = types.str; default = "en"; };
    site-name = mkOption { type = types.str; default = "Cookbook"; };
  };

  config = mkIf cfg.enable {
    security.acme.certs."${ acme.challenge-host }".extraDomainNames = [ cfg.vhost ];

    users.groups.www-data.members = [ "nginx" "uwsgi" ];

    services.nginx = {
      enable = true;
      
      virtualHosts."${cfg.vhost}" = {
        forceSSL = true;
        useACMEHost = acme.challenge-host;
        locations."/static/".alias = "${cookbook}/static/";
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

          pythonPackages = self: with self; [ cookbook ];
          socket = "${config.services.uwsgi.runDir}/cookbook.sock";
          module = "cookbook:app";
          env = ["COOKBOOK_CONFIG=${cookbook-config}"];
        };
      };
    };
  };
}
