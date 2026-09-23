{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  gservices = config.globals.services;
  cfg = config.glyph.monitoring.prometheus;
  prometheus-scrape-configs = lib.flatten (
    config.glyph.transpose-here [
      "prometheus"
      "scrape"
    ]
  );
in
{
  options.glyph.monitoring.prometheus.enable = mkEnableOption "prometheus metrics scraper";

  config = mkIf cfg.enable {
    sops.secrets."prometheus/auth/user" = { };
    sops.secrets."prometheus/auth/hash" = { };
    sops.templates."prometheus-basic-auth.yml" = {
      content = ''
        basic_auth_users:
          ${config.sops.placeholder."prometheus/auth/user"}: ${
            config.sops.placeholder."prometheus/auth/hash"
          }
      '';
      owner = "prometheus";
    };

    services.prometheus = {
      enable = true;
      listenAddress = gservices.prometheus.bindaddr;
      port = gservices.prometheus.bindport;
      webConfigFile = config.sops.templates."prometheus-basic-auth.yml".path;
      webExternalUrl = "https://${gservices.prometheus.domain}/";

      globalConfig = {
        scrape_interval = "1m";
        evaluation_interval = "1m";
      };

      scrapeConfigs = prometheus-scrape-configs;
    };

    security.acme.certs."${gservices.prometheus.domain}" = {
      reloadServices = [ "nginx.service" ];
      group = "nginx";
    };

    glyph.transpose.headscale.dns = [
      (gservices.headscale.mkDnsEntry gservices.prometheus.host)
    ];

    services.nginx = {
      virtualHosts."${gservices.prometheus.domain}" = gservices.nginx.mkReverseProxy {
        proto = "http";
        domain = "${gservices.prometheus.bindaddr}";
        port = gservices.prometheus.bindport;
        listen = [ gservices.headscale.myAddr ];
        acme_host = gservices.prometheus.domain;
      };
    };
  };
}
