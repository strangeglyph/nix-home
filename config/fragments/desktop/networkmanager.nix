{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.glyph.networkmanager;
in
{
  options.glyph.networkmanager = {
    enable = mkOption {
      description = "Enable networkmanager and companion tools";
      default = config.glyph.dm.enable;
      type = types.bool;
    };
    randomizeMac = mkOption {
      description = "Randomize interface mac addresses";
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      ethernet.macAddress = mkIf cfg.randomizeMac "random";
      wifi = mkIf cfg.randomizeMac {
        macAddress = "random";
        scanRandMacAddress = true;
      };
    };

    environment.systemPackages = [ pkgs.networkmanagerapplet ];
  };
}
