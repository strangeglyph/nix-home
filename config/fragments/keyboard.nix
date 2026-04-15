{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkMerge
    mkIf
    mkDefault
    types
    ;
  cfg = config.glyph.keyboard;
in
{
  options.glyph.keyboard = mkOption {
    description = "Keyboard layout";
    type = types.enum [
      "qwerty"
      "qwertz"
    ];
    default = "qwertz";
  };

  config = mkMerge [
    (mkIf (cfg == "qwerty") {
      console.keyMap = mkDefault "us";

      services.xserver = {
        xkb.layout = mkDefault "us";
        xkb.variant = mkDefault "altgr-intl";
        xkb.options = mkDefault "eurosign:e,compose:caps";
      };
    })
    (mkIf (cfg == "qwertz") {
      console = {
        keyMap = mkDefault "de";
      };

      services.xserver = {
        xkb.layout = mkDefault "de";
        xkb.variant = mkDefault "deadacute";
        xkb.options = mkDefault "compose:caps";
      };
    })
  ];
}
