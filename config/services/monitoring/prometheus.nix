{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
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

    sops.secrets."prometheus/auth/user" = {
      owner = "prometheus";
    };
    sops.secrets."prometheus/auth/hash" = {
      owner = "prometheus";
    };
    sops.secrets."prometheus/auth/pass" = {
      owner = "prometheus";
    };
    sops.templates."prometheus-basic-auth.yml" = {
      content = ''
        basic_auth_users:
          ${config.sops.placeholder."prometheus/auth/user"}: ${
            config.sops.placeholder."prometheus/auth/hash"
          }
      '';
      owner = "prometheus";
    };

    sops.secrets."prometheus/mail/pass" = { };
    sops.secrets."prometheus/telegram/token" = { };
    sops.secrets."prometheus/telegram/chat" = { };

    systemd.services.alertmanager.serviceConfig.LoadCredential = [
      "mail_pass:${config.sops.secrets."prometheus/mail/pass".path}"
      "telegram_token:${config.sops.secrets."prometheus/telegram/token".path}"
      "telegram_chat:${config.sops.secrets."prometheus/telegram/chat".path}"
      "web.yml:${config.sops.templates."prometheus-basic-auth.yml".path}"
    ];

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

      alertmanagers = [
        {
          basic_auth = {
            username_file = config.sops.secrets."prometheus/auth/user".path;
            password_file = config.sops.secrets."prometheus/auth/pass".path;
          };

          static_configs = [
            {
              targets = [
                "${gservices.alertmanager.bindaddr}:${toString gservices.alertmanager.bindport}"
              ];
            }
          ];
        }
      ];

      alertmanager = {
        enable = true;
        listenAddress = gservices.alertmanager.bindaddr;
        port = gservices.alertmanager.bindport;
        extraFlags = [
          "--web.config.file=\${CREDENTIALS_DIRECTORY}/web.yml"
        ];

        configuration = {
          global = {
            smtp_smarthost = "${config.globals.email.smtp}:465";
            smtp_hello = config.globals.email.smtp;
            smtp_from = "Eye in the Sky <${config.glyph.confidentials.emails.monitoring}>";
            smtp_auth_username = config.glyph.confidentials.emails.monitoring;
            smtp_auth_password_file = "$CREDENTIALS_DIRECTORY/mail_pass";
            telegram_bot_token_file = "$CREDENTIALS_DIRECTORY/telegram_token";
          };
          route = {
            group_by = [
              "service"
              "host"
            ];
            group_wait = "1m";
            group_interval = "5m";
            repeat_interval = "24h";
            receiver = "mail";
            routes = [
              {
                matchers = [ "severity=critical" ];
                receiver = "telegram";
              }
            ];
          };
          inhibit_rules = [
            {
              source_matchers = [ "severity=critical" ];
              target_matchers = [ "severity=warning" ];
              equal = [
                "alertname"
                "service"
                "host"
              ];
            }
          ];
          receivers =
            let
              email_config = {
                to = config.glyph.confidentials.emails.monitoring_target;
              };
              telegram_config = {
                chat_id_file = "$CREDENTIALS_DIRECTORY/telegram_chat";
              };
            in
            [
              {
                name = "mail";
                email_configs = [
                  email_config
                ];
              }
              {
                name = "telegram";
                email_configs = [
                  email_config
                ];
                telegram_configs = [
                  telegram_config
                ];
              }
            ];
        };
      };
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
