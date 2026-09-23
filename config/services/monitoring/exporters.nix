{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkMerge
    types
    optionalAttrs
    length
    ;
  gservices = config.globals.services;
  host = config.networking.hostName;
  cfg = config.glyph.monitoring.exporters;
in
{
  options.glyph.monitoring.exporters = mkOption {
    description = "List of prometheus exporters to configure";
    default = { };
    type = types.listOf types.str;
  };

  config =
    let
      groups-config = optionalAttrs (length cfg > 0) {
        prometheus-exporters = { };
      };

      sops-config = optionalAttrs (length cfg > 0) {
        secrets."prometheus/auth/user" = { };
        secrets."prometheus/auth/hash" = { };
        secrets."prometheus/auth/pass" = { };
        templates."exporter-web.yml" = {
          content = ''
            basic_auth_users:
              ${config.sops.placeholder."prometheus/auth/user"}: ${
                config.sops.placeholder."prometheus/auth/hash"
              }
          '';
          group = "prometheus-exporters";
          mode = "0440";
        };
      };

      mkAcme = name: {
        ${gservices.prometheus.mkMonitoringDomain name} = {
          reloadServices = [ "nginx.service" ];
          group = "nginx";
        };
      };
      acme-config = mkMerge (map mkAcme cfg);

      mkExporter = name: {
        ${name} = {
          enable = true;
          listenAddress = "127.0.0.1";
          port = gservices.prometheus.exporters.${name}.port;
          group = "prometheus-exporters";
          extraFlags = [
            "--web.config.file=${config.sops.templates."exporter-web.yml".path}"
          ];
        };
      };
      exporter-config = mkMerge (map mkExporter cfg);

      mkVHost = name: {
        ${gservices.prometheus.mkMonitoringDomain name} = gservices.nginx.mkReverseProxy {
          proto = "http";
          domain = "127.0.0.1";
          port = gservices.prometheus.exporters.${name}.port;
          listen = [ gservices.headscale.myAddr ];
          acme_host = gservices.prometheus.mkMonitoringDomain name;
        };
      };
      vhost-config = mkMerge (map mkVHost cfg);

      mkDns = name: {
        name = gservices.prometheus.mkMonitoringDomain name;
        type = "A";
        value = gservices.headscale.myAddr;
      };
      dns-config = map mkDns cfg;

      mkScrapeConfig = name: {
        job_name = "${name}-${host}";
        scheme = "https";
        basic_auth = {
          # TODO Prometheus module is not RFC42 compliant
          # Tracking issue: github:nixos/nixpkgs#354199
          #username_file = config.sops.secrets."prometheus/auth/user".path;
          username = config.glyph.confidentials.prometheus.basic_auth.username;
          # TODO This is a bit of a hack since it refers to a path on the local host
          # instead of the path on the prometheus host, and we rely on the fact that
          # they are the same.
          # Alternative would be to approach this as in transposed kanidm configs,
          # i.e. nodes.${prometheus_host}..., but this would require hardcoding the
          # prometheus host
          password_file = config.sops.secrets."prometheus/auth/pass".path;
        };
        static_configs = [
          {
            targets = [
              (gservices.prometheus.mkMonitoringDomain name)
            ];
          }
        ];
      };
      scrape-config = map mkScrapeConfig cfg;
    in
    {
      users.groups = groups-config;
      sops = sops-config;
      security.acme.certs = acme-config;
      services.prometheus.exporters = exporter-config;
      services.nginx.virtualHosts = vhost-config;
      glyph.transpose.headscale.dns = dns-config;
      glyph.transpose.prometheus.scrape = scrape-config;
    };
}
