{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./alacritty.nix
  ];

  options.glyph.users = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          term = lib.mkOption {
            description = "Terminal to use";
            type = types.enum [ ];
          };
        };
      }
    );
  };
}
