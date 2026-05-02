{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glyph.tools.gaming;
in
{
  options.glyph.tools.gaming = mkEnableOption "Gaming programs";

  config = mkIf cfg {
    programs.steam.enable = true;
  };
}
