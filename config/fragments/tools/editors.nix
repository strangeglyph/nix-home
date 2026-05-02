{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glyph.tools.editors;
in
{
  options.glyph.tools.editors = mkEnableOption "Editors";

  config = mkIf cfg {
    environment.systemPackages = [
      pkgs.obsidian
      pkgs.vscode-fhs
    ];
  };
}
