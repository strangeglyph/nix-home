{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  inherit (config) glib;
  theme = config.glyph.theme;
  scheme = theme.color.schemes.${theme.color.noctalia};
  cfg = config.glyph.dm.noctalia;
in
{
  options = {
    glyph.dm.noctalia = {
      enable = mkOption {
        description = "Enable the Noctalia shell";
        default = config.glyph.dm.niri.enable;
        type = types.bool;
      };
      animations = mkOption {
        description = "Enable animations for Noctalia (causes sluggish behavior on slower machines)";
        default = true;
        type = types.bool;
      };
      shadows = mkOption {
        description = "Enable shadows for Noctalia (causes some overhead, and may be better suited to compositor)";
        default = true;
        type = types.bool;
      };
    };

    glyph.theme.color.noctalia = mkOption {
      description = "Noctalia color scheme";
      type = types.str;
      default = config.glyph.theme.color.niri;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.hicolor-icon-theme ]; # Soft-required by noctalia

    home-manager.users = glib.eachHumanUser' (
      name: hm_args: {
        imports = [
          inputs.noctalia.homeModules.default
        ];

        systemd.user.services.noctalia.Unit.PartOf = lib.mkForce [ "niri-session.target" ];

        programs = {
          noctalia = {
            enable = true;
            systemd.enable = true;
            # nb. Noctalia v5 has GUI override files which may shadow values here
            # Consider merging GUI overrides here regularly
            settings = {
              shell = {
                niri_overview_type_to_launch_enabled = true;
                font_family = "Sans Serif";
                time_format = "{:%H:%M}";
                date_format = "%A, %x";
                offline_mode = false;
                polkit_agent = false; # conflict with other agents
                settings_show_advanced = true;
                show_location = false;
                app_icon_colorize = true;
                app_icon_color = "on_surface"; # material UI key
                clipboard_enabled = false;
                avatar_path = "/dev/null";
                setup_wizard_enabled = false;

                animation = {
                  enabled = cfg.animations;
                  speed = 1.5;
                };

                shadow = {
                  direction = "down";
                  alpha = 0.5;
                };

                panel = {
                  transparency_mode = "soft";
                  borders = true;
                  shadow = cfg.shadows;

                  launcher_placement = "floating";
                  launcher_position = "centered";
                  clipboard_placement = "floating";
                  clipboard_position = "centered";

                  control_center_placement = "attached";
                  wallpaper_placement = "attached";

                  session_placement = "floating";
                  session_position = "centered";

                  open_near_click_control_center = true;
                  open_near_click_launcher = false;

                  open_near_click_wallpaper = false;
                  open_near_click_clipboard = false;
                  open_near_click_session = false;
                };

                launcher = {
                  categories = false;
                  show_icons = false;
                };

                session = {
                  actions = [
                    { action = "lock"; }
                    { action = "suspend"; }
                    { action = "logout"; }
                    { action = "reboot"; }
                    { action = "shutdown"; }
                  ];
                };

                screen_corners.enabled = false;
              };
              osd = {
                # On-Screen-Display - overlays for vol and backlight changes etc
                position = "top_right";
                orientation = "horizontal";
                scale = 1.0;
                background_opacity = 0.6;

                kinds = {
                  volume = true;
                  volume_output = true;
                  volume_input = true;

                  brightness = true;
                  wifi = true;
                  bluetooth = true;
                  power_profile = true;
                  caffeine = true; # idle inhibitor
                  dnd = true;
                };
              };
              lockscreen = {
                blurred_desktop = false;
                blur_intensity = 0;
                tint_intensity = 0;
              };
              lockscreen_widgets = {
                enabled = true;
                schema_version = 2;
                widget_order = [
                  "login-box@eDP-1"
                  "login-box@DP-4"
                  "login-box@DP-5"
                  "clock@eDP-1"
                  "clock@DP-4"
                  "clock@DP-5"
                ];
                grid = {
                  cell_size = 16;
                  major_interval = 4;
                  visible = true;
                };
                widget =
                  let
                    mk-login-box = output: cy: {
                      type = "login_box";
                      box_height = 64.0;
                      box_width = 448.0;
                      cx = 232.5;
                      cy = cy;
                      output = output;
                      rotation = 0.0;
                      settings = {
                        layout = "compact";
                        background_color = "surface_variant";
                        background_opacity = 0.0;
                        background_radius = 0.0;
                        center_password_text = false;
                        input_opacity = 1.0;
                        input_radius = 0.0;
                        show_caps_lock = true;
                        show_keyboard_layout = true;
                        show_login_button = false;
                        show_session_buttons = false;
                        show_media = false;
                        show_weather = false;
                        show_unlock_hint = false;
                      };
                    };
                    mk-clock = output: cy: {
                      box_height = 256.0;
                      box_width = 512.0;
                      cx = 232.5;
                      cy = cy;
                      output = output;
                      rotation = 0.0;
                      type = "clock";
                      settings = {
                        background_opacity = 0.0;
                        center_text = true;
                        color = "tertiary";
                        font_family = "Jost*";
                        shadow = true;
                      };
                    };
                  in
                  {
                    "login-box@eDP-1" = mk-login-box "eDP-1" 939;
                    "login-box@DP-4" = mk-login-box "DP-4" 1039;
                    "login-box@DP-5" = mk-login-box "DP-5" 1039;
                    "clock@eDP-1" = mk-clock "eDP-1" 827;
                    "clock@DP-4" = mk-clock "DP-4" 927;
                    "clock@DP-5" = mk-clock "DP-5" 927;
                  };
              };
              bar = {
                order = [ "main" ];

                main = {
                  position = "top";
                  enabled = true;
                  auto_hide = false;
                  reserve_space = true;
                  layer = "top";

                  thickness = 48;
                  background_opacity = 0.6;
                  border = "outline";
                  border_width = 2;

                  shadow = cfg.shadows;
                  contact_shadow = cfg.shadows;

                  panel_overlap = 1;
                  radius = 12;
                  margin_edge = 8;
                  margin_ends = 32;
                  padding = 16;
                  widget_spacing = 8;
                  scale = 1.0;
                  font_weight = "regular";

                  capsule = false;
                  capsule_fill = "surface_variant"; # material UI key
                  capsule_opacity = 0.3;

                  dead_zone.actions = {
                    middle = "settings-open-widget";
                  };

                  start = [
                    "group:sysmon-group"
                    "network"
                  ];
                  center = [ "my-workspaces" ];
                  end = [
                    "brightness"
                    "volume"
                    "battery"
                    "notifications"
                    "tray"
                    "clock"
                  ];

                  capsule_group = [
                    {
                      id = "sysmon-group";
                      members = [
                        "sysmon-cpu"
                        "sysmon-mem"
                        "sysmon-disk"
                      ];
                      opacity = 0.0;
                    }
                  ];
                };
              };
              dock = {
                background_opacity = 0.6;
              };
              widget = {
                launcher = {
                  type = "launcher";
                  glyph = "north-star";
                };
                sysmon-cpu = {
                  type = "sysmon";
                  stat = "cpu_usage";
                  visualization = "gauge";
                  show_value = false;
                };
                sysmon-disk = {
                  type = "sysmon";
                  stat = "disk_used_pct";
                  path = "/";
                  visualization = "gauge";
                  show_value = false;
                };
                sysmon-mem = {
                  type = "sysmon";
                  stat = "ram_pct";
                  visualization = "gauge";
                  show_value = false;
                };
                network = {
                  type = "network";
                  show_label = true;
                };
                media = {
                  type = "media";
                  art_size = 32;
                  hide_when_no_media = true;
                  title_scroll = "always";
                };
                my-workspaces = {
                  type = "glyph/niri-icon-workspaces:niri-workspaces";
                  workspace = {
                    nixos = "north-star";
                    firefox = "brand-firefox";
                    mail = "mail";
                    project = "code";
                    writing = "align-justified";
                    notes = "pencil";
                  };
                };
                workspace = {
                  type = "taskbar";
                  group_by_workspace = true;
                  show_workspace_label = true;
                  workspace_label_placement = "corner";
                  workspace_group_capsule = true;
                  group_single_icon_per_app = true;
                  show_active_indicator = true;
                };
                brightness = {
                  type = "brightness";
                  show_label = true;
                  actions = {
                    scroll_up = "brightness-up 10%";
                    scroll_down = "brightness-down 10%";
                  };
                };
                volume = {
                  type = "volume";
                  show_label = true;
                  mute_color = "on_surface";
                  actions = {
                    scroll_up = "volume-up 5%";
                    scroll_down = "volume-down 5%";
                  };
                };
                battery = {
                  type = "battery";
                  display_mode = "graphic";
                  show_label = true;
                };
                notifications = {
                  type = "notifications";
                };
                tray = {
                  type = "tray";
                  drawer = true;
                };
                clock = {
                  type = "clock";
                  format = "%d.%m. %H:%M";
                  vertical_format = "%H\n%M";
                };
              };
              control_center = {
                shortcuts = [
                  { type = "wifi"; }
                  { type = "bluetooth"; }
                  { type = "caffeine"; }
                  { type = "nightlight"; }
                  { type = "power_profile"; }
                  { type = "notifications"; }
                ];
              };
              desktop_widgets = {
                enabled = false;
              };
              wallpaper = {
                enabled = true;
                fill_mode = "crop";
                fill_color = scheme.mnemonics.background.main;
                transition = [
                  "fade"
                  "honeycomb"
                ];
                transition_duration = 3000;
                transition_on_startup = true;
                directory = "${hm_args.config.home.homeDirectory}/Wallpapers";

                automation = {
                  enabled = true;
                  interval_seconds = 1800;
                  order = "random";
                  recursive = true;
                };
              };
              backdrop = {
                enabled = true;
                blur_intensity = 0.5;
                tint_intensity = 0.2;
              };
              theme = {
                mode = "dark";
                source = "wallpaper";
                wallpaper_scheme = "faithful";
                templates = {
                  enable_builtin_templates = true;
                  builtin_ids = [
                    "gtk3"
                    "gtk4"
                    "qt"
                    "kcolorscheme"
                  ];

                  enable_community_templates = true;
                  community_ids = [
                    "discord"
                    "steam"
                    "telegram"
                  ];

                  user = {
                    niri = {
                      input_path = glib.flakeRootPath "assets/noctalia/niri_colors.kdl";
                      output_path = "$XDG_CONFIG_HOME/niri/colors.kdl";
                      pre_hook = "niri msg action do-screen-transition --delay 100";
                    };
                  };
                };
              };
              audio = {
                enable_overdrive = false;
                enable_sounds = false;
              };
              battery = {
                warning_threshold = 20;
              };
              brightness = {
                enable_ddcutil = false;
              };
              calendar = {
                enabled = false;
              };
              idle = {
                pre_action_fade_seconds = 10.0;
                behavior_order = [ "lock" ];
                behavior = {
                  "idle-behavior" = {
                    timeout = 600;
                    command = "lock";
                    enabled = true;
                  };
                };
              };
              nightlight = {
                enabled = true;
              };
              notification = {
                enable_daemon = true;
                show_app_name = true;
                position = "top_right";
                layer = "top";
                scale = 1.0;
                background_opacity = 0.8;
                offset_x = 32;
                offset_y = 16;
                collapse_on_dismiss = true;
                blacklist = [ ];
              };
              system = {
                monitor = {
                  enabled = true;
                  cpu_poll_seconds = 2.0;
                  memory_poll_seconds = 2.0;
                  disk_poll_seconds = 10.0;
                };
              };
              plugins = {
                enabled = [ "glyph/niri-icon-workspaces" ];
                source = [
                  {
                    name = "glyph-dev";
                    kind = "path";
                    location = "~/Projects/noctalia-plugins";
                  }
                ];
              };
            };
          };
        };
      }
    );
  };
}
