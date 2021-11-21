{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.cookbook;
  acme = config.security.acme;
  cookbook-repo = pkgs.fetchFromGitHub {
    owner = "strangeglyph";
    repo = "cookbook";
    rev = "master";
    sha256 = "0lz4p0vbavy7r678cx652vrh5qr0pcjvfi9np9d72n9sq4sg46m1";
  };
  cookbook = pkgs.python3Packages.callPackage "${ cookbook-repo }/derivation.nix" {};
  cookbook-recipes = pkgs.fetchFromGitHub {
    owner = "strangeglyph";
    repo = "cookbook-recipes";
    rev = "master";
    sha256 = "0xgzl8r7h3n3iadahlc81y4j0mb3csbl5b6kcr64fj8pi4pvra2g";
  };
  cookbook-config = pkgs.writeText "config.json" (builtins.toJSON {
    SECRET_KEY = builtins.readFile ../secrets/cookbook-session-key;
    COOKBOOK_LOCATION = cfg.recipe-folder;
    defaultlang = cfg.default-language;
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
          pyargv = cookbook-config;
        };
      };
    };
  };
}
