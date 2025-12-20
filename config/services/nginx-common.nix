{ pkgs, lib, config,  ... }:
with lib;
let
  cfg = config.security.acme;
in
{

  options.security.acme = {
    http-challenge-host = mkOption { type = types.nullOr types.str; default = null; };
  };

  config.users.groups.acme.members = [ "nginx" ];

  config.services.nginx = {
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedUwsgiSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    appendHttpConfig = ''
      log_format vhost_combined '[$time_local] $server_name ($host) from $remote_addr - '
                                '"$request" $status $body_bytes_sent '
                                '"$http_referer" "$http_user_agent"';
      
      access_log /var/log/nginx/other_vhosts_access.log vhost_combined;
    '';

    virtualHosts = mkIf (cfg.http-challenge-host != null) {
      "${ cfg.http-challenge-host }" = {
        enableACME = true;

        locations."~* \.(php)$" = {
          return = "301 https://ash-speed.hetzner.com/10GB.bin";
        };
      };
    };
  };
}
