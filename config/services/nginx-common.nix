{ pkgs, lib, config,  ... }:
with lib;
let
  cfg = config.security.acme;
in
{

  options.security.acme = {
    challenge-host = mkOption { type = types.str; };
  };

  config.services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."${ cfg.challenge-host }" = {
       enableACME = true;
    };
  };
}
