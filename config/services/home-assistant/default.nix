{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glyph.home-assistant;
  gservices = config.globals.services;
in
{
  options.glyph.home-assistant = {
    enable = mkEnableOption "home-assistant";
  };

  config = mkIf cfg.enable {
    glyph.vpn.domains.${gservices.home-assistant.host} = {
      nginx.upstream_port = gservices.home-assistant.bindport;
    };

    users.users.hass.extraGroups = [ "dialout" ]; # for conbee/deconz

    systemd.tmpfiles.settings."10-hass" = {
      "/var/lib/hass/automations.yaml".f = {
        user = "hass";
        group = "hass";
        mode = "0644";
      };
      "/var/lib/hass/scenes.yaml".f = {
        user = "hass";
        group = "hass";
        mode = "0644";
      };
      "/var/lib/hass/scripts.yaml".f = {
        user = "hass";
        group = "hass";
        mode = "0644";
      };
    };

    services.home-assistant = {
      enable = true;
      # via wiki
      extraComponents = [
        # Components required to complete the onboarding
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"
        # Recommended for fast zlib compression
        # https://www.home-assistant.io/integrations/isal
        "isal"
      ]
      ++ [
        "tradfri"
        "deconz"
        "zha"
      ];
      config = {
        http = {
          server_host = "127.0.0.1";
          server_port = gservices.home-assistant.bindport;
          trusted_proxies = [
            "127.0.0.1"
          ];
          use_x_forwarded_for = true;
        };
        default_config = {

        };

        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";
      };
    };
  };
}
