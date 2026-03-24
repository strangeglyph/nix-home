{
  pkgs,
  lib,
  config,
  ...
}:

let
  stylix = config.stylix;
in
{
  programs.waybar = {
    enable = config.wayland.windowManager.sway.enable;
    style = import ./waybar-style.nix { inherit stylix; };
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        modules-left = [
          "tray"
          "cpu"
          "memory"
          "disk"
          "network"
        ];
        modules-center = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-right = [
          "backlight"
          "pulseaudio"
          "custom/notifications"
          "battery"
          "clock"
        ];

        tray = {
          icon-size = 21;
          spacing = 10;
        };

        cpu = {
          interval = 5;
          format = " {usage:2}%";
        };

        memory = {
          interval = 5;
          format = " {percentage}%";
        };

        disk = {
          interval = 5;
          format = "󰋊 {percentage_used}%";
        };

        network = {
          interval = 5;
          format-ethernet = "󰈀";
          format-wifi = "{icon} {essid} ({signalStrength}%)";
          format-disconnected = "󰤮";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
        };

        "sway/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "󰠮";
            "8" = "";
            "9" = "";
            "urgent" = "󰀦";
            "default" = "";
          };
        };

        "sway/mode" = {
        };

        backlight = {
          format = "{icon} {percent}%";
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +10%";
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
          format-icons = [
            "󰃞"
            "󰃟"
            "󰃠"
          ];
        };

        pulseaudio = {
          scroll-step = 5;
          format = "{icon} {volume}%";
          format-muted = "󰝟 {volume}%";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          format-icons.default = [
            ""
            ""
            ""
          ];
        };

        "custom/notifications" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "󱥁";
            inhibited-notification = "󱥁";
            dnd-notification = " 󱥁";
            dnd-inhibited-notification = " 󱥁";
            none = "󰍥";
            inhibited-none = "󰍥";
            dnd-none = " 󰍥";
            dnd-inhibited-none = " 󰍥";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client --subscribe-waybar";
          on-click = "swaync-client --toggle-panel --skip-wait";
          on-click-right = "swaync-client --toggle-dnd --skip-wait";
          escape = true;
        };

        battery = {
          interval = 5;
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱟢";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        clock = {
          interval = 5;
          format = "{:%d.%m. %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
          locale = "de_DE.UTF-8";
          timezone = "Europe/Berlin";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };
      };
    };
  };
}
