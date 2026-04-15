{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glyph.dev.rust;
in
{
  options.glyph.dev.python = mkEnableOption "Python IDEs and tooling";

  config = mkIf cfg {
    environment.systemPackages = [
      # disabled in favor of vscode
      # jetbrains.pycharm
    ];
  };
}
