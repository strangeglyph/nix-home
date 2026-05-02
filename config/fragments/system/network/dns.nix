{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.glyph.nameservers = mkOption {
    description = "Nameservers to use";
    type = types.listOf types.str;
    default = [
      "9.9.9.9"
      "1.1.1.1"
    ];
  };

  config = {
    networking.nameservers = config.glyph.nameservers;
    services.resolved.enable = true;
  };
}
