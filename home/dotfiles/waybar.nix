{ pkgs, lib, ... }:

{
    enable = true;
    style = ./waybar-style.css;
    settings = {
        mainBar = {
            layer = "top";
            position = "bottom";
            modules-left = [ "tray" "cpu" "memory" "disk" "network" ];
            modules-center = [ "sway/workspaces" "sway/mode" ];
            modules-right = [ "backlight" "pulseaudio" "battery" "clock" ];

            tray = {
                icon-size = 21;
                spacing = 10;
            };
            
            cpu = {
                interval = 5;
                format = " {usage}%";
            };

            memory = {
                interval = 5;
                format = " {used:0.1f}GB ({percentage}%)"; 
            };

            disk = {
                interval = 5;
                format = "󰋊 {used:1f} ({percentage_used}%)";
            };

            network = {
                interval = 5;
                format-ethernet = "󰈀 {}";
                format-wifi = "  {essid} ({signalStrength}%)";
                format-disconnected = "󰤮";
                onclick = "${pkgs.networkmanagerapplet}/bin/nm-applet";
            };

            "sway/workspaces" = {
                format = "{icon}";
                format-icons = {
                    "1" = "";
                    "2" = "";
                    "8" = "";
                    "9" = "";
                    "urgent" = "󰀦";
                    "default" = "";
                };
            };

            "sway/mode" = {
                "format" = "<span style=\"monospace\">{}</span>";
            };

            backlight = {
                format = "{icon} {percent}%";
                on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +10%";
                on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set -10%";
                format-icons = [ "󰃞" "󰃟" "󰃠" ];
            };

            pulseaudio = {
                scroll-step = 5;
                format = "{icon} {volume}%";
                format-muted = "󰝟 {volume}%";
                on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
                format-icons.default = [ "" "" "" ];
            };

            battery = {
                interval = 5;
                format = "{icon} {capacity}%";
                format-charging = "󰂄 {capacity}%";
                format-plugged = "󱟢 {capacity}%";
                format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            };

            clock = {
                interval = 5;
                format = "{:%d.%m. %H:%M}";
                locale = "de_DE";
                timezone = "Europe/Berlin";
            };
        };
    };
}
