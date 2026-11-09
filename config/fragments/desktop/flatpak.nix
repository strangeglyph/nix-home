{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.glyph.dm;
in
{
  options.glyph.dm.flatpak = {
    enable = mkOption {
      description = "enable the flatpak service";
      default = cfg.enable;
      type = types.bool;
    };
  };

  config = mkIf cfg.flatpak.enable {
    glyph.dm.portal.enable = true;

    services.flatpak.enable = true;
  };
}
