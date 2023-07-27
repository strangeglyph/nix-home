{ pkgs, lib, ... }:

let
  mod = "Mod4";
in {
  enable = true;
  package = pkgs.swayfx;
  config = {
    modifier = "${mod}";
    defaultWorkspace = "workspace number 1";
    fonts = {
      names = [ "SauceCodePro Nerd Font" ];
      size = 12.0;
    };
    # gruvbox-dark compatible colors
    colors = rec {
      focused = rec {
        border = "#fe8019"; # soft orange
        background = "#282828"; # gruvbox "bg0"
        text = "#ebdbb2"; # gruvbox "fg" (offwhite)
        indicator = border;
        childBorder = border;
      };
      focusedInactive = rec {
        border = "#835397"; # purple
        childBorder = border;
        indicator = border;
        text = "#ebdbb2";
        background = "#3c3836"; # gruvbox "bg1"
      };
      unfocused = rec {
        border = "#835397"; # purple
        childBorder = border;
        indicator = border;
        text = "#d5c4a1"; # gruvbox "fg2" (darkened fg)
        background = "#3c3836";
      };
      urgent = rec {
        border = "#cc241d"; # red
        childBorder = border;
        indicator = border;
        text = border;
        background = "#282828";
      };
      placeholder = unfocused;
    };

    terminal = "${pkgs.alacritty}/bin/alacritty";
    gaps = {
      outer = 10;
      inner = 10;
    };
    assigns = {
      "8" = [{ class = "(?i)firefox"; }];
      "9" = [{ class = "(?i)thunderbird"; }];
    };
    workspaceOutputAssign = [
      { workspace = "8"; output = "DisplayPort-2 eDP"; }
      { workspace = "9"; output = "DisplayPort-2 eDP"; }
    ];
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
    output = {
      "CMN 1409 0" = { position = "1920,0"; };
      "DisplayPort-2" = { position = "0,0"; };
    };
    startup = [
      { command = "firefox"; }
      { command = "thunderbird"; }
      { command = "alacritty"; }
      { command = "nm-applet"; }
      { command = "${pkgs.sway-contrib.inactive-windows-transparency}/bin/inactive-windows-transparency.py --opacity .80"; }
      { command = "${pkgs.deadd-notification-center}"; }
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
  '';

  wrapperFeatures = {
    gtk = true;
  };
}
