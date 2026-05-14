{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.glyph.tools.science;
in
{
  options.glyph.tools.science = mkEnableOption "Enable science tools";

  config = mkIf cfg {
    environment.systemPackages = with pkgs; [
      texstudio
      texliveFull
    ];
  };
}
