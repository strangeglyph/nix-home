{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.glyph.power;
in
{
  options.glyph.power = {
    enable = mkOption {
      description = "Power management settings";
      default = config.glyph.dm.enable;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services = {
      acpid.enable = true;
      logind.settings.Login.HandlePowerKey = "suspend";

      # Power management
      tuned.enable = true;
      upower.enable = true;
    };
  };
}
