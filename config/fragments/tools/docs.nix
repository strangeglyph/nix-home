{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    ;
  cfg = config.glyph.tools.docs;
in
{
  options.glyph.tools.docs = {
    enable = mkOption {
      description = "Enable document tools";
      default = config.glyph.dm.enable;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libreoffice
      evince
    ];
  };
}
