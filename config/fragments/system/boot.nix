{ lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
in
{
  options.glyph.boot = mkOption {
    description = "Apply default boot config";
    default = true;
    type = types.bool;
  };

  config = mkIf config.glyph.boot {
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 4;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.tmp.useTmpfs = true;
    
    boot.initrd.systemd.network.wait-online.enable = false;

    systemd.network.wait-online.enable = false;
  };
}
