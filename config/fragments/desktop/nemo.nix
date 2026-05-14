{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.glyph.dm.portal;
  glib = config.glib;
  nemo = pkgs.nemo-with-extensions;
in
{
  config = mkIf cfg.enable {
    services = {
      dbus = {
        packages = [ nemo ];
      };
    };

    environment.systemPackages = [
      pkgs.file-roller # compression gui
      nemo
    ];

    xdg = {
      mime.defaultApplications = {
        "inode/directory" = [ "nemo.desktop" ];
        "application/x-gnome-saved-search" = [ "nemo.desktop" ];
      };
    };

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/nemo/preferences" = {
              click-policy = "double";
              date-format = "iso";
              show-hidden-files = true;
              show-toggle-extra-pane-toolbar = true;
              size-prefixes = "base1-";
              tooltips-in-icon-view = false;
              tooltips-in-list-view = false;
            };
            "org/nemo/preferences/menu-config" = {
              selection-menu-in = true;
              selection-menu-open-in-new-tab = true;
              selection-menu-open-as-root = false;
            };
          };
        }
      ];
    };

    home-manager.users = glib.eachHumanUser (
      _: cfg: {
        dconf = {
          settings = {
            # For the nemo terminal emulator
            "org/cinnamon/desktop/applications/terminal".exec = "${cfg.term}";
            "org/cinnamon.desktop/interface".can-change-accels = true;
          };
        };
        home.file = {
          ".gnome2/accels/nemo".text = ''
            (gtk_accel_path "<Actions>/DirViewActions/OpenInTerminal" "F4")
          '';
        };
      }
    );
  };
}
