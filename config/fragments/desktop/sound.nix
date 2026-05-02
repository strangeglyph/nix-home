{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.glyph.sound;
in
{
  options.glyph.sound = {
    enable = mkOption {
      description = "Enable sound server";
      default = config.glyph.dm.enable;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # Real-time scheduling for pipewire
    security.rtkit.enable = true;

    services = {
      pipewire = {
        enable = true;
        # APIs
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        # Session manager
        wireplumber.enable = true;
      };
    };
  };
}
