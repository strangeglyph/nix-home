{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  gservices = config.globals.services;
  cfg = config.glyph.monitoring.node;
in
{
  options.glyph.monitoring.node = {
    enable = mkOption {
      description = "Enable node metrics collection";
      type = types.bool;
      default = true;
    };
  };

  config = {
    glyph.monitoring.exporters = [ "node" ];
  };
}
