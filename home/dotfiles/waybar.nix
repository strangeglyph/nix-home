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
                format = " {usage:2}%";
            };

            memory = {
                interval = 5;
                format = " {used:0.1f}GB ({percentage}%)"; 
            };

            disk = {
                interval = 5;
                format = "󰋊 {used:03} ({percentage_used}%)";
            };

            network = {
                interval = 5;
                format-ethernet = "󰈀";
                format-wifi = "{icon} {essid} ({signalStrength}%)";
                format-disconnected = "󰤮";
                format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
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
                format-plugged = "󱟢";
                format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            };

            clock = {
                interval = 5;
                format = "{:%d.%m. %H:%M}";
                tooltip-format = "<tt><small>{calendar}</small></tt>";
                locale = "de_DE";
                timezone = "Europe/Berlin";
                calendar = {
                    mode = "month";
                    mode-mon-col =  3;
                    weeks-pos = "right";
                    on-scroll =  1;
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
}
