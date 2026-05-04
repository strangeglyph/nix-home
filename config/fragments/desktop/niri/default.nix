{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.glyph.dm.niri;
  theme = config.glyph.theme;
  scheme = theme.color.schemes.${theme.color.niri};
  inherit (config) glib;
in
{
  imports = [
    inputs.niri.nixosModules.niri
    ./noctalia.nix
  ];

  options.glyph.dm = {
    default-wm = mkOption {
      type = types.enum [ "niri" ];
    };
    niri = {
      enable = mkOption {
        description = "Enable Niri DM";
        default = config.glyph.dm.enable;
        type = types.bool;
      };
      mod-key = mkOption {
        description = "Modifier key for Niri control actions";
        default = "Super";
        type = types.str;
      };
      mod-key-nested = mkOption {
        description = "Modifier key for Niri control action when running in nested mode";
        default = "Alt";
        type = types.str;
      };
      animations = mkOption {
        description = "Enable animations for Niri (may cause sluggish behavior on slower machines)";
        default = true;
        type = types.bool;
      };
      shadows = mkOption {
        description = "Enable shadows for Niri (causes some overhead)";
        default = true;
        type = types.bool;
      };
    };
  };

  options.glyph.theme.color.niri = mkOption {
    description = "Niri color scheme";
    type = types.str;
    default = theme.color.default-scheme;
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    home-manager.users = glib.eachHumanUser (
      name: ucfg: hm-args: {
        programs.niri = {
          settings = {
            binds = {
              "XF86AudioRaiseVolume".action.spawn-sh =
                "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume".action.spawn-sh =
                "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              "XF86AudioMute".action.spawn-sh =
                "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "XF86MonBrightnessUp".action.spawn-sh = "${lib.getExe pkgs.brightnessctl} set +10%";
              "XF86MonBrightnessDown".action.spawn-sh = "${lib.getExe pkgs.brightnessctl} set 10%-";
              "XF86AudioPlay".action.spawn-sh = "${lib.getExe pkgs.playerctl} play";
              "XF86AudioPause".action.spawn-sh = "${lib.getExe pkgs.playerctl} pause";
              "XF86AudioNext".action.spawn-sh = "${lib.getExe pkgs.playerctl} next";
              "XF86AudioPrev".action.spawn-sh = "${lib.getExe pkgs.playerctl} previous";

              "Mod+O".action.show-hotkey-overlay = [ ];
              "Mod+Return".action.spawn = "alacritty";
              "Mod+Shift+Q".action.close-window = [ ];

              "Print".action.screenshot = {
                show-pointer = false;
              };
              "Ctrl+Print".action.screenshot-window = {
                write-to-disk = false;
              };

              # TODO noctalia lock instead
              #"${mod}+l" = mkSpawn "${pkgs.swaylock-effects}/bin/swaylock -f";
              #"${mod}+Alt+Left" = mkAct "move workspace to output left";
              #"${mod}+Alt+Right" = mkAct "move workspace to output right";
            };

            clipboard = {
              disable-primary = true;
            };

            workspaces = {
              term = { };
              writing = { };
              notes = { };
              editor = { };
              firefox = { };
              mail = { };
            };

            input = {
              focus-follows-mouse.enable = true;
              mod-key = cfg.mod-key;
              mod-key-nested = cfg.mod-key-nested;
              touchpad = {
                click-method = "button-areas";
                disabled-on-external-mouse = true;
                dwt = true; # Disabled while typing
                natural-scroll = true;
              };
            };

            layout =
              let
                mkGradient = from: to: {
                  gradient = {
                    angle = 150;
                    from = from;
                    to = to;
                    in' = "oklch shorter hue";
                    relative-to = "workspace-view";
                  };
                };
                cat = scheme.mnemonics.category;
                bg = scheme.mnemonics.background;
              in
              {
                border = {
                  enable = true;
                  width = 2;
                  active = mkGradient cat.focus cat.accent;
                  inactive = mkGradient cat.accent bg.secondary;
                  urgent = mkGradient cat.alert cat.warn;
                };
                focus-ring = {
                  enable = false;
                };
                insert-hint = {
                  enable = true;
                  display.gradient = {
                    from = cat.focus;
                    to = cat.alert;
                    in' = "oklch shorter hue";
                    relative-to = "window";
                  };
                };
                shadow = {
                  enable = cfg.shadows;
                  color = scheme.mnemonics.background.main;
                };
                background-color = bg.main;

                always-center-single-column = true;
                center-focused-column = "on-overflow";

                gaps = 16;
                struts = {
                  bottom = 16;
                  top = 16;
                  left = 64;
                  right = 64;
                };
              };

            animations = {
              enable = cfg.animations;
            };

            window-rules = [
              {
                draw-border-with-background = false;
                geometry-corner-radius =
                  let
                    r = 8.0;
                  in
                  {
                    top-left = r;
                    top-right = r;
                    bottom-left = r;
                    bottom-right = r;
                  };
                clip-to-geometry = true;
              }
              {
                matches = [
                  { app-id = "^Alacritty$"; }
                ];
                default-column-width.proportion = 0.45;
              }
              {
                matches = [
                  {
                    app-id = "^Alacritty$";
                    at-startup = true;
                  }
                ];
                open-on-workspace = "term";
              }
              {
                matches = [
                  { app-id = "^obsidian$"; }
                ];
                open-on-workspace = "notes";
              }
              {
                matches = [
                  { app-id = "^thunderbird$"; }
                ];
                open-on-workspace = "mail";
              }
              {
                matches = [
                  { app-id = "^firefox(-nightly)?$"; }
                ];
                open-on-workspace = "firefox";
              }
              {
                matches = [
                  { app-id = "^code$"; }
                ];
                open-on-workspace = "editor";
              }
            ];

            layer-rules = [

            ];
          };
        };
      }
    );
  };
}
