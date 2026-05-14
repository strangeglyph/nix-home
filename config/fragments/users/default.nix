{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    mkMerge
    ;
in
{
  options.glyph.users = mkOption {
    description = "Define non-system users (i.e. ones that have login privileges and a shell)";
    default = { };
    type = types.attrsOf (
      types.submodule {
        options = {
          privileged = lib.mkOption {
            description = "Grant additional privileges to this user";
            default = false;
            type = types.bool;
          };
          with-pw = lib.mkOption {
            description = "Set a default password to enable use of `passwd` and `sudo`";
            default = false;
            type = types.bool;
          };
        };
      }
    );
  };

  config = {

    users.users = config.glib.eachHumanUser (
      name: cfg:
      mkMerge [
        {
          isNormalUser = true;
          home = "/home/${name}";

          extraGroups = [
            "networkmanager"
            "scanner"
            "lp"
            "audio"
            "video"
            "input"
          ]
          ++ lib.optionals cfg.privileged [
            "wheel"
            "wireshark"
          ];
          initialHashedPassword = if cfg.with-pw then config.glyph.confidentials.initial-unix-pw else null;
        }
      ]
    );

    # usb stick mounting, required for udiskie
    services.udisks2.enable = true;

    # user management
    services.userborn.enable = true;

    home-manager.users = lib.mkMerge [
      {
        root = {
          home.username = "root";
          home.homeDirectory = "/root";
          home.stateVersion = "21.05";

          xdg.enable = true;
        };
      }
      (config.glib.eachHumanUser (
        name: cfg: {
          home.username = name;
          home.homeDirectory = "/home/${name}";

          xdg.enable = true;

          home.stateVersion = "21.05";

          services = {
            # Automount usb sticks
            udiskie = {
              enable = true;
              automount = true;
            };
          };
        }
      ))
    ];
  };
}
