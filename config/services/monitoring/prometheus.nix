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
    services.prometheus = {
      enable = true;
      listenAddress = gservices.headscale.myAddr;
      port = gservices.prometheus.port;

      globalConfig = {
        scrape_interval = "1m";
        evaluation_interval = "1m";
      };

      scrapeConfigs = prometheus-scrape-configs;
    };

    glyph.transpose.headscale.dns = [
      (gservices.headscale.mkDnsEntry gservices.prometheus.host)
    ];
  };
}
