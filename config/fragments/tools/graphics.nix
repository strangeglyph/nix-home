{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glyph.tools.graphics;
in
{
  options.glyph.tools.graphics = mkEnableOption "Graphics and design";

  config = mkIf cfg {
    services.xserver.wacom.enable = config.glyph.dm.enable;

    environment.systemPackages = [
      pkgs.inkscape
    ];
  };
}
