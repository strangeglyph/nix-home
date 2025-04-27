{ lib, config, osConfig, pkgs, ... }:

let
  stylix = config.stylix;
  colors = stylix.base16Scheme;
  fonts = stylix.fonts;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # conflicts with uswm
    settings = let
      mod = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      launcher = "${pkgs.wofi}/bin/wofi --show drun";
      lock = "${pkgs.swaylock-effects}/bin/swaylock -f";
      screenshot = "${pkgs.grimblast}/bin/grimblast";
      audio = "pactl";
      backlight = "${pkgs.brightnessctl}/bin/brightnessctl";
      media = "${pkgs.playerctl}/bin/playerctl";
    in
    {

      monitor = [ ", preferred, auto, 1" ];
      
      workspace = [
        "1, defaultName:term"
        "2, defaultName:code"
        "3, defaultName:notes"
        "8, defaultName:web"
        "9, defaultName:mail"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        # Fix some dragging issues with XWayland
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        # tags
        "tag +term, class:alacritty"
        "tag +term, class:wezterm"
        "tag +term, class:kitty"
        "tag +code, class:texstudio"
        "tag +code, class:pycharm" # TODO window class
        "tag +notes, class:obsidian"
        "tag +web, class:firefox"
        "tag +web, class:firefox-nightly"
        "tag +mail, class:thunderbird"
        # Auto-spawn on correct workspace
        "workspace 2, tag:code"
        "workspace 3, tag:notes"
        "workspace 8, tag:web"
        "workspace 9, tag:mail"
        # No dimming for web and video
        "nodim on, tag:web"
        "opaque on: tag:web"
        #"nodim on, content:video"
        #"opaque on, content:video"
        # Resize indicator
        "bordercolor rgb(${colors.highlight}), tag:resize"
      ];

      binds.allow_workspace_cycles = true;

      # e = repeat, l = ignore lockscreen
      bindel = [
        # Media Control
        ", XF86AudioRaiseVolume, exec, ${audio} set-sing-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, ${audio} set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioMute, exec, ${audio} set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, ${backlight} set +10%"
        ", XF86MonBrightnessDown, exec, ${backlight} set 10%-"
      ];

      bindl = [ 
        ", XF86AudioPlay, exec, ${media} play"
        ", XF86AudioPause, exec, ${media} pause"
        ", XF86AudioNext, exec, ${media} next"
        ", XF86AudioPrev, exec, ${media} previous"
      ];
      
      bind = [
        # Launchers
        ", Print, exec, ${screenshot} copy area"
        "${mod}, Return, exec, ${terminal}"
        "${mod}, D, exec, ${launcher}"
        "${mod}, L, exec, ${lock}"
        # Focus Naviagation
        "${mod}, 1, workspace, 1"
        "${mod}, 2, workspace, 2"
        "${mod}, 3, workspace, 3"
        "${mod}, 4, workspace, 4"
        "${mod}, 5, workspace, 5"
        "${mod}, 6, workspace, 6"
        "${mod}, 7, workspace, 7"
        "${mod}, 8, workspace, 8"
        "${mod}, 9, workspace, 9"
        "${mod}, 0, workspace, 10"
        "${mod}, Left, movefocus, l"
        "${mod}, Right, movefocus, r"
        "${mod}, Up, movefocus, u"
        "${mod}, Down, movefocus, d"
        "${mod}, Tab, workspace, previous"
        "${mod}, H, layoutmsg, preselect r" # dwindle next right
        "${mod}, V, layoutmsg, preselect d"  # dwindle next down
        # Window Manipulation
        "${mod}, R, tagwindow, +resize"
        "${mod}, R, submap, resize"
        "${mod} Shift, F, togglefloating, active"
        "${mod} Shift, F11, fullscreen, 0"
        "${mod} Shift, P, pseudo" # dwindle free resize
        "${mod} Shift, Left, movewindow, l"
        "${mod} Shift, Right, movewindow, r"
        "${mod} Shift, Up, movewindow, u"
        "${mod} Shift, Down, movewindow, d"
        "${mod} Shift, Q, killactive"
        "${mod} Shift, 1, movetoworkspacesilent, 1"
        "${mod} Shift, 2, movetoworkspacesilent, 2"
        "${mod} Shift, 3, movetoworkspacesilent, 3"
        "${mod} Shift, 4, movetoworkspacesilent, 4"
        "${mod} Shift, 5, movetoworkspacesilent, 5"
        "${mod} Shift, 6, movetoworkspacesilent, 6"
        "${mod} Shift, 7, movetoworkspacesilent, 7"
        "${mod} Shift, 8, movetoworkspacesilent, 8"
        "${mod} Shift, 9, movetoworkspacesilent, 9"
        "${mod} Shift, 0, movetoworkspacesilent, 10"
      ];

      # mouse binds
      bindm = [
        "${mod} Shift, mouse:272, movewindow" # lmb
        "${mod} Shift, mouse:273, resizewindow" # rmb
      ];

      exec-once = [
        "firefox-nightly"
        "thunderbird"
        "texstudio"
        "obsidian"
        "[workspace 1 silent] alacritty"
        "nm-applet"
      ];

      general = {
        border_size = 2;
        "col.active_border" = "rgb(${colors.accent})";
        "col.inactive_border" = "rgb(${colors.alt-base})";

        gaps_in = 10;
        gaps_out = "20,20,10,20"; # top, right, bottom, left
      };

      dwindle = {
        pseudotile = true;
        force_split = 2; # split to right
        preserve_split = true;
      };


      decoration = {
        rounding = 4;

        inactive_opacity = 0.8;
        dim_inactive = true;
        dim_strength = 0.2;

        blur = {
          enabled = true;
          size = 10;
        };

        shadow = {
          enabled = true;
          color = "rgba(${colors.main-base}cc)";
          offset = "0 2";
        };

      };

      animations.enabled = false;

      input = with osConfig.services.xserver; {
        kb_layout = xkb.layout;
        kb_variant = xkb.variant;
        kb_options = xkb.options;

        touchpad = {
          disable_while_typing = true;
          natural_scroll = true;
          tap-to-click = true;
        };

        tablet = {
            output = "current";
        };
      };

      misc = {
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        focus_on_activate = true; # for e.g. cross-app link clicks to automatically bring up the firefox workspace
        middle_click_paste = false;
      };

      cursor = {
        no_warps = true;
      };

      ecosystem = {
        #no_donation_nag = true;
      };
    };
    extraConfig = ''
      submap = resize
      bind = , Escape, tagwindow, -resize
      bind = , Escape, submap, reset
      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      binde = , up, resizeactive, 0 -10
      binde = , down, resizeactive, 0 10
      submap = reset
    '';
  };
}
