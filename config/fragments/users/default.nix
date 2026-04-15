{
  lib,
  pkgs,
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
        };
      }
    );
  };

  config = {
    users.users = mkMerge [
      {
        root.shell = pkgs.fish;
      }
      (config.glib.eachHumanUser (
        name: cfg:
        mkMerge [
          {
            isNormalUser = true;
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
          }
        ]
      ))

    ];

    # usb stick mounting, required for udiskie
    services.udisks2.enable = true;

    home-manager.users = lib.mkMerge [
      {
        root = {
          home.username = "root";
          home.homeDirectory = "/root";
          home.stateVersion = "21.05";
        };
      }
      (config.glib.eachHumanUser (
        name: cfg: {
          home.username = name;
          home.homeDirectory = "/home/${name}";

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
