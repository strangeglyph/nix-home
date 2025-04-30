{ pkgs, lib, config, ... }:

let
  mod = "Mod4";
  stylix = config.stylix;
  colors = stylix.base16Scheme;
in {
  imports = [
    ./notification-center.nix
    ./waybar.nix
    ./swaylock.nix
    ./swayidle.nix
    ./kanshi.nix
  ];

  wayland.windowManager.sway = {
    checkConfig = false; # bugfix for nix-community/home-manager #5379
    package = pkgs.swayfx;
    config = {
      modifier = "${mod}";
      defaultWorkspace = "workspace 1";
      fonts = {
        names = [ stylix.fonts.monospace.name ];
        size = stylix.fonts.sizes.desktop;
      };
      # gruvbox-dark compatible colors
      colors = rec {
        focused = rec {
          border = colors.highlight;
          background = colors.main-base;
          text = colors.main-text;
          indicator = border;
          childBorder = border;
        };
        focusedInactive = rec {
          border = colors.accent;
          childBorder = border;
          indicator = border;
          text = colors.main-text;
          background = colors.alt-base;
        };
        unfocused = rec {
          border = colors.accent;
          childBorder = border;
          indicator = border;
          text = colors.main-text;
          background = colors.alt-base;
        };
        urgent = rec {
          border = colors.error;
          childBorder = border;
          indicator = border;
          text = border;
          background = colors.main-base;
        };
        placeholder = unfocused;
      };

      terminal = "${pkgs.alacritty}/bin/alacritty";
      gaps = {
        outer = 10;
        inner = 10;
        bottom = 5;
      };
      assigns = {
        "2" = [{ app_id = "(?i)texstudio"; }];
        "3" = [{ app_id = "(?i)obsidian"; }];
        "8" = [{ app_id = "(?i)firefox"; }];
        "9" = [{ app_id = "(?i)thunderbird"; }];
      };
      floating = {
        criteria = [
          { class = "floatingTerm"; }
        ];
      };
      focus.mouseWarping = false;
      input = {
        "type:keyboard" = { xkb_layout = "us"; xkb_variant = "altgr-intl"; xkb_options = "eurosign:e,compose:caps"; };
        # dwt = disable while typing
        "type:touchpad" = { drag = "enabled"; dwt = "enabled"; tap = "enabled"; scroll_method = "two_finger"; natural_scroll = "enabled"; };
      };
      startup = [
        { command = "firefox-nightly"; }
        { command = "thunderbird"; }
        { command = "texstudio"; }
        { command = "obsidian"; }
        { command = "alacritty"; }
        { command = "nm-applet"; }
        { command = "${pkgs.sway-contrib.inactive-windows-transparency}/bin/inactive-windows-transparency.py --opacity .80"; }
        { command = "swaymsg -t SUBSCRIBE -m \"['workspace']\" | jq --unbuffered -r 'select(.change == \"focus\") | .current.output' | xargs -L1 swaymsg input type:tablet_tool map_to_output"; }
      ];
      keybindings = lib.mkOptionDefault {
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10%";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
        "XF86AudioPlay"  = "exec playerctl play";
        "XF86AudioPause" = "exec playerctl pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
        "${mod}+l" = "exec ${pkgs.swaylock-effects}/bin/swaylock -f";
        "${mod}+Alt+Left" = "move workspace to output left"; 
        "${mod}+Alt+Right" = "move workspace to output right"; 
      };
      window = {
       titlebar = false;
       border = 1;
      };

      bars = [
        {
          command = "${pkgs.waybar}/bin/waybar";
        }
      ];
    };

    # swayfx
    extraConfig = ''
      blur enable
      corner_radius 2
      shadows enable
      shadow_blur_radius 7
      layer_effects "waybar" {
        blur enable;
        blur_ignore_transparent enable;
      }
    '';

    wrapperFeatures = {
      gtk = config.wayland.windowManager.sway.enable;
    };
  };
}
