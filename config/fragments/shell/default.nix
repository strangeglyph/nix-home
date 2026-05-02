{
  lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption;
  inherit (config) glib;
in
{
  imports = [
    ./fish.nix
    ./starship.nix
  ];

  options.glyph.users = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          shell = mkOption {
            description = "The shell to use for this user";
            type = types.enum [ ];
          };
        };
      }
    );
  };

  config = {
    home-manager.users = glib.eachHumanUserAndRoot' (name: {
      programs.fzf.enable = true;
    });
  };
}
