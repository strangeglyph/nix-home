{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glyph.tools."3d-printing";
in
{
  options.glyph.tools."3d-printing" = mkEnableOption "3d-printing and modelling tools";

  config = mkIf cfg {
    environment.systemPackages = [
      pkgs.prusa-slicer
      pkgs.openscad
      pkgs.freecad
    ];
  };
}
