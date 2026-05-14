{
  config,
  lib,
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
    ./noctalia.nix
    ../sway/swaylock.nix
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
      candy = {
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
        blur = mkOption {
          description = "Enable blur";
          default = true;
          type = types.bool;
        };
        other = mkOption {
          description = "Enable other candy (rounded corners etc, transparency etc)";
          default = true;
          type = types.bool;
        };
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
      useNautilus = false;
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "A scrollable-tiling Wayland compositor";
        binPath = "/run/current-system/sw/bin/niri-session";
      };
    };

    environment.systemPackages = [
      pkgs.xwayland-satellite
    ];

    systemd = {
      # via codeberg:bananad3v/niri-nix, but use unclear
      #user.units."niri.service" = {
      #  text = ''
      #    [Service]
      #    X-StopIfChanged=false
      #    X-RestartIfChanged=false
      #  '';
      #};
    };

    home-manager.users = glib.eachHumanUser (
      name: ucfg: hm-args: {
        xdg.configFile."niri/config.kdl".text =
          let
            mkGradient =
              from: to:
              ''from="${from}" to="${to}" angle=150 relative-to="workspace-view" in="oklch shorter hue"'';
            cat = scheme.mnemonics.category;
            bg = scheme.mnemonics.background;
          in
          ''
            prefer-no-csd

            input {
              focus-follows-mouse

              keyboard {
                repeat-delay 200
                repeat-rate 35
              }

              touchpad {
                tap
                dwt
                natural-scroll
                click-method "clickfinger"
              }

              tablet {
                // map-to-output "eDP-1"
                map-to-focused-output
              }

              mouse {
                accel-speed 0.15
              }
            }

            cursor { 
              xcursor-theme "${hm-args.config.home.pointerCursor.name}"
              xcursor-size ${toString hm-args.config.home.pointerCursor.size}
              hide-when-typing 
              hide-after-inactive-ms 5000 
            }

            output "eDP-1" {
              scale 1.1
            }

            binds {
              XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"; }
              XF86AudioLowerVolume allow-when-locked=true { spawn-sh "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
              XF86AudioMute        allow-when-locked=true { spawn-sh "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }

              XF86AudioPlay        allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} play"; }
              XF86AudioPause       allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} pause"; }
              XF86AudioNext        allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} next"; }
              XF86AudioPrev        allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} previous"; }

              XF86MonBrightnessUp  allow-when-locked=true { spawn-sh "${lib.getExe pkgs.brightnessctl} set +10%"; }
              XF86MonBrightnessDown allow-when-locked=true { spawn-sh "${lib.getExe pkgs.brightnessctl} set 10%-"; }

              Mod+O                repeat=false           { toggle-overview; }
              Mod+Shift+Slash      repeat=false           { show-hotkey-overlay; }

              Mod+Return hotkey-overlay-title="Open terminal" { spawn "alacritty"; }
              Mod+D hotkey-overlay-title="Open launcher"  { 
                ${
                  if config.glyph.dm.noctalia.enable then
                    ''spawn-sh "noctalia msg panel-toggle launcher"''
                  else
                    ''spawn "dmenu"''
                }; 
              }
              ${lib.optionalString config.glyph.dm.noctalia.enable ''
                Mod+S hotkey-overlay-title="Open Noctalia control panel" { spawn-sh "noctalia msg panel-toggle control-panel"; }
                Mod+Shift+S hotkey-overlay-title="Open Noctalia settings" { spawn-sh "noctalia msg settings-toggle"; }
              ''}
              Mod+L hotkey-overlay-title="Lock screen"    { 
                ${
                  if config.glyph.dm.noctalia.enable then
                    ''spawn-sh "noctalia msg session lock"''
                  else
                    ''spawn-sh "swaylock -f"''
                };
              }
              
              Mod+Left                                    { focus-column-or-monitor-left; }
              Mod+Down                                    { focus-window-or-monitor-down; }
              Mod+Up                                      { focus-window-or-monitor-up; }
              Mod+Right                                   { focus-column-or-monitor-right; }

              Mod+Shift+Left                              { move-column-left-or-to-monitor-left; }
              Mod+Shift+Down                              { move-window-down; }
              Mod+Shift+Up                                { move-window-up; }
              Mod+Shift+Right                             { move-column-right-or-to-monitor-right; }

              Mod+Ctrl+Left                               { focus-monitor-left; }
              Mod+Ctrl+Down                               { focus-monitor-down; }
              Mod+Ctrl+Up                                 { focus-monitor-up; }
              Mod+Ctrl+Right                              { focus-monitor-right; }

              Mod+Shift+Ctrl+Left                         { move-column-to-monitor-left; }
              Mod+Shift+Ctrl+Down                         { move-column-to-monitor-down; }
              Mod+Shift+Ctrl+Up                           { move-column-to-monitor-up; }
              Mod+Shift+Ctrl+Right                        { move-column-to-monitor-right; }

              Mod+Shift+Alt+Left                          { move-workspace-to-monitor-left; }
              Mod+Shift+Alt+Down                          { move-workspace-to-monitor-down; }
              Mod+Shift+Alt+Up                            { move-workspace-to-monitor-up; }
              Mod+Shift+Alt+Right                         { move-workspace-to-monitor-right; }

              Mod+1                                       { focus-workspace "term"; }
              Mod+2                                       { focus-workspace "writing"; }
              Mod+3                                       { focus-workspace "notes"; }
              Mod+4                                       { focus-workspace "editor"; }
              Mod+5                                       { focus-workspace 5; }
              Mod+6                                       { focus-workspace 6; }
              Mod+7                                       { focus-workspace 7; }
              Mod+8                                       { focus-workspace "firefox"; }
              Mod+9                                       { focus-workspace "mail"; }
              Mod+Shift+1                                 { move-column-to-workspace "term"; }
              Mod+Shift+2                                 { move-column-to-workspace "writing"; }
              Mod+Shift+3                                 { move-column-to-workspace "notes"; }
              Mod+Shift+4                                 { move-column-to-workspace "editor"; }
              Mod+Shift+5                                 { move-column-to-workspace 5; }
              Mod+Shift+6                                 { move-column-to-workspace 6; }
              Mod+Shift+7                                 { move-column-to-workspace 7; }
              Mod+Shift+8                                 { move-column-to-workspace "firefox"; }
              Mod+Shift+9                                 { move-column-to-workspace "mail"; }

              Mod+Comma                                   { consume-or-expel-window-left; }
              Mod+Period                                  { consume-or-expel-window-right; }

              Mod+R                                       { switch-preset-column-width; }
              Mod+Shift+R                                 { switch-preset-column-width-back; }
              Mod+F                                       { maximize-column; }
              Mod+Shift+F                                 { fullscreen-window; }
              Mod+Minus                                   { set-column-width "-10%"; }
              Mod+Equal                                   { set-column-width "+10%"; }
              Mod+C                                       { center-column; }

              Mod+Shift+Q                                 { close-window; }

              Print                                       { screenshot show-pointer=false; }
              Ctrl+Print                                  { screenshot-window write-to-disk=false; }

              Mod+Escape           allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
            }

            gestures {
              hot-corners { off; }
            }

            layout {
              gaps 16
              struts {
                top 0
                bottom 8
                left 16
                right 16
              }
              center-focused-column "on-overflow"
              always-center-single-column
              default-column-display "normal"
              tab-indicator { hide-when-single-tab; }

              background-color "${bg.main}"

              preset-column-widths {
                proportion 1.0
                proportion 0.5
              }

              default-column-width { proportion 1.0; }

              border {
                width 2;
                active-gradient ${mkGradient cat.focus cat.accent}
                inactive-gradient ${mkGradient cat.accent bg.secondary}
                urgent-gradient ${mkGradient cat.alert cat.warn}
              }

              focus-ring { off; }

              shadow {
                ${if cfg.candy.shadows then "on" else "off"}
                color "${bg.main}"
                softness 30
                spread 5
                offset x=0 y=5
              }

              insert-hint {
                gradient ${mkGradient "${cat.focus}7f" "${cat.alert}7f"}
              }
            }

            workspace "term" {}
            workspace "writing" {}
            workspace "notes" {}
            workspace "editor" {}
            workspace "firefox" {}
            workspace "mail" {}

            clipboard { disable-primary; }

            spawn-at-startup "noctalia"
            spawn-at-startup "${lib.getExe pkgs.alacritty}"
            spawn-at-startup "firefox-nightly"
            spawn-at-startup "${lib.getExe pkgs.thunderbird}"
            spawn-at-startup "${lib.getExe pkgs.obsidian}"
            spawn-at-startup "${lib.getExe pkgs.code}"

            overview {
              zoom 0.5
              backdrop-color "${bg.secondary}"
              workspace-shadow {
                softness 40
                spread 10
                offset x=0 y=10
                color "${bg.status}"
              }
            }

            hotkey-overlay {
              skip-at-startup
              hide-not-bound
            }

            blur {
              ${if cfg.candy.blur then "on" else "off"}
              passes 3
              offset 5.0
              noise 0.02
              saturation 1.5
            }

            ${lib.optionalString cfg.candy.other ''
              // rounded corner and seethrough borders
              window-rule { 
                geometry-corner-radius 8
                clip-to-geometry true
                //draw-border-with-background true
              }
            ''}

            ${lib.optionalString cfg.candy.blur ''
              window-rule {
                background-effect {
                  xray true
                  blur true
                  noise 0.05
                  saturation 2
                }
              }
            ''}

            // alert screencast windows
            window-rule {
              match is-window-cast-target=true

              focus-ring {
                active-color "${cat.alert}"
                inactive-color "${cat.alert}"
              }

              shadow {
                color "${cat.alert}7f"
              }
            }

            // Open the Firefox picture-in-picture window as floating with 480×270 size.
            window-rule {
                match app-id="firefox(-nightly)?$" title="^Picture-in-Picture$"

                open-floating true
                default-column-width { fixed 480; }
                default-window-height { fixed 270; }
            }

            window-rule {
              match app-id="^Alacritty$"
              default-column-width { proportion 0.5; }
            }

            window-rule {
              match app-id="^obsidian$"
              open-on-workspace "notes"
              open-maximized true
            }

            window-rule {
              match app-id="^thunderbird$"
              open-on-workspace "mail";
              open-maximized true
            }

            window-rule {
              match app-id="^firefox(-nightly)?$"
              open-on-workspace "firefox"
              open-maximized true
            }

            window-rule {
              match app-id="^code$"
              open-on-workspace "editor";
              open-maximized true
            }

            // Floating Noctalia settings window.
            window-rule {
              match app-id="dev.noctalia.Noctalia.Settings"
              open-floating true
              default-column-width { fixed 1080; }
              default-window-height { fixed 920; }
            }

            animations {
              ${if cfg.candy.animations then "on" else "off"}
            }

            recent-windows {
              debounce-ms 500
              open-delay-ms 100

              highlight {
                active-color "${cat.focus}"
                urgent-color "${cat.alert}"
                corner-radius 24
                padding 24
              }

              previews {
                max-height 480
                max-scale 0.5
              }

              binds {
                  Alt+Tab         { next-window; }
                  Alt+Shift+Tab   { previous-window; }
                  Alt+grave       { next-window     filter="app-id"; }
                  Alt+Shift+grave { previous-window filter="app-id"; }

                  Mod+Tab         { next-window; }
                  Mod+Shift+Tab   { previous-window; }
                  Mod+grave       { next-window     filter="app-id"; }
                  Mod+Shift+grave { previous-window filter="app-id"; }
              }
            }

            layer-rule {
              match namespace="^noctalia-backdrop"
              place-within-backdrop true
            }

            layer-rule {
              match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"
              background-effect {
                xray false
              }
            }

            include "animations.kdl"
            include optional=true "colors.kdl"
          '';
        xdg.configFile."niri/animations.kdl".text = ''
          animations {
            window-open {
              duration-ms 100
              curve "linear"
              custom-shader r"
                vec4 pixelate_open(vec3 coords_geo, vec3 size_geo) {
                    // Discard pixels outside window bounds
                    if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                        return vec4(0.0);
                    }
                    float progress = niri_clamped_progress;
                    float border_width = 0.008; // Adjust based on your border size
                    vec2 coords = coords_geo.xy;
                    // Check if we're in the border region
                    bool in_border = coords.x < border_width || coords.x > (1.0 - border_width) ||
                                    coords.y < border_width || coords.y > (1.0 - border_width);
                    // Only pixelate the inner content, not the border
                    if (!in_border) {
                        float pixel_size = (1.0 - progress) * 0.1;
                        if (pixel_size > 0.0) {
                            coords = floor(coords / pixel_size) * pixel_size + pixel_size * 0.5;
                        }
                        // Clamp sampling to avoid border area
                        coords = clamp(coords, border_width, 1.0 - border_width);
                    }
                    vec3 new_coords = vec3(coords, 1.0);
                    vec3 coords_tex = niri_geo_to_tex * new_coords;
                    vec4 color = texture2D(niri_tex, coords_tex.st);
                    color.a *= progress;
                    return color;
                }
                vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                  return pixelate_open(coords_geo, size_geo);
                }
              "
            }
            window-close {
              duration-ms 100
              curve "linear"
              custom-shader r"
                vec4 pixelate_close(vec3 coords_geo, vec3 size_geo) {
                    // Discard pixels outside window bounds
                    if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                        return vec4(0.0);
                    }
                    float progress = niri_clamped_progress;
                    float border_width = 0.008;
                    vec2 coords = coords_geo.xy;
                    // Check if we're in the border region
                    bool in_border = coords.x < border_width || coords.x > (1.0 - border_width) ||
                                    coords.y < border_width || coords.y > (1.0 - border_width);
                    // Only pixelate the inner content, not the border
                    if (!in_border) {
                        float pixel_size = progress * 0.1;
                        if (pixel_size > 0.0) {
                            coords = floor(coords / pixel_size) * pixel_size + pixel_size * 0.5;
                        }
                        // Clamp sampling to avoid border area
                        coords = clamp(coords, border_width, 1.0 - border_width);
                    }
                    vec3 new_coords = vec3(coords, 1.0);
                    vec3 coords_tex = niri_geo_to_tex * new_coords;
                    vec4 color = texture2D(niri_tex, coords_tex.st);
                    color.a *= (1.0 - progress);
                    return color;
                }
                vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                  return pixelate_close(coords_geo, size_geo);
                }
              "
            }
          }
        '';
      }
    );
  };
}
