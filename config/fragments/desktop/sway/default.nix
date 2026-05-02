{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.glyph.dm.sway;
  mod = cfg.mod-key;
  theme = config.glyph.theme;
  scheme = theme.color.schemes.${theme.color.sway};
  inherit (config) glib;
in
{
  imports = [
    ./swayidle.nix
    ./waybar.nix
    ./swaylock.nix
    ./kanshi.nix
    ./notification-center.nix
  ];

  options.glyph.dm = {
    default-wm = mkOption {
      type = types.enum [ "sway" ];
      default = "sway";
    };
    sway = {
      enable = mkOption {
        description = "Enable Sway DM";
        default = config.glyph.dm.enable;
        type = types.bool;
      };
      mod-key = mkOption {
        description = "Mod key to use";
        default = "Mod4";
        type = types.str;
      };
    };
  };

  options.glyph.theme.color.sway = mkOption {
    description = "Sway color scheme";
    type = types.str;
    default = theme.color.default-scheme;
  };

  config = mkIf cfg.enable {
    programs.sway.enable = true;

    home-manager.users = glib.eachHumanUser' (name: {
      wayland.windowManager.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        checkConfig = false; # bugfix for nix-community/home-manager #5379
        package = pkgs.swayfx;
        config = {
          modifier = "${mod}";
          defaultWorkspace = "workspace 1";
          fonts = {
            names = [ theme.fonts.monospace.name ];
            size = theme.fonts.sizes.desktop;
          };
          # gruvbox-dark compatible colors
          colors = with scheme.mnemonics; {
            focused = rec {
              border = category.focus;
              background = scheme.mnemonics.background.main;
              text = foreground.main;
              indicator = border;
              childBorder = border;
            };
            focusedInactive = rec {
              border = category.accent;
              childBorder = border;
              indicator = border;
              text = foreground.main;
              background = scheme.mnemonics.background.secondary;
            };
            unfocused = rec {
              border = category.accent;
              childBorder = border;
              indicator = border;
              text = foreground.main;
              background = scheme.mnemonics.background.secondary;
            };
            urgent = rec {
              border = category.alert;
              childBorder = border;
              indicator = border;
              text = foreground.main;
              background = scheme.mnemonics.background.main;
            };
            placeholder = rec {
              border = category.accent;
              childBorder = border;
              indicator = border;
              text = foreground.main;
              background = scheme.mnemonics.background.secondary;
            };
          };

          terminal = "${pkgs.alacritty}/bin/alacritty";
          gaps = {
            outer = 10;
            inner = 10;
            bottom = 5;
          };
          assigns = {
            "2" = [ { app_id = "(?i)texstudio"; } ];
            "3" = [ { app_id = "(?i)obsidian"; } ];
            "4" = [ { app_id = "(?i)code"; } ];
            "8" = [ { app_id = "(?i)firefox"; } ];
            "9" = [ { app_id = "(?i)thunderbird"; } ];
          };
          floating = {
            criteria = [
              { class = "floatingTerm"; }
            ];
          };
          focus.mouseWarping = false;
          input = {
            "type:keyboard" = {
              xkb_layout = config.services.xserver.xkb.layout;
              xkb_variant = config.services.xserver.xkb.variant;
              xkb_options = config.services.xserver.xkb.options;
            };
            # dwt = disable while typing
            "type:touchpad" = {
              drag = "enabled";
              dwt = "enabled";
              tap = "enabled";
              scroll_method = "two_finger";
              natural_scroll = "enabled";
            };
          };
          startup = [
            { command = "alacritty"; }
            { command = "firefox-nightly"; }
            { command = "thunderbird"; }
            { command = "code"; }
            { command = "obsidian"; }
            { command = "nm-applet"; }
            {
              command = "${pkgs.sway-contrib.inactive-windows-transparency}/bin/inactive-windows-transparency.py --opacity .80";
            }
            # drawing tablet mapping
            {
              command = "swaymsg -t SUBSCRIBE -m \"['workspace']\" | jq --unbuffered -r 'select(.change == \"focus\") | .current.output' | xargs -L1 swaymsg input type:tablet_tool map_to_output";
            }
          ];
          keybindings = lib.mkOptionDefault {
            "XF86AudioRaiseVolume" =
              "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" =
              "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" =
              "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} set +10%";
            "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} set 10%-";
            "XF86AudioPlay" = "exec ${lib.getExe pkgs.playerctl} play";
            "XF86AudioPause" = "exec ${lib.getExe pkgs.playerctl} pause";
            "XF86AudioNext" = "exec ${lib.getExe pkgs.playerctl} next";
            "XF86AudioPrev" = "exec ${lib.getExe pkgs.playerctl} previous";
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
      };
    });
  };
}
