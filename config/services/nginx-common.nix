{ pkgs, lib, config,  ... }:
with lib;
let
  cfg = config.security.acme;
in
{

  options.security.acme = {
    http-challenge-host = mkOption { type = types.str; };
  };

  config.users.groups.acme.members = [ "nginx" ];

  config.services.nginx = {
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedUwsgiSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = mkIf (builtins.hasAttr "http-challenge-host" cfg) {
      "${ cfg.http-challenge-host }" = {
        enableACME = true;
      };
    };
  };
}
