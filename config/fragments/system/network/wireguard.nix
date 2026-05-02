{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.glyph.wireguard;
in
{
  options.glyph.wireguard = {
    enable = mkOption {
      description = "Wireguard tools";
      type = types.bool;
      default = lib.attrsToList (config.glyph.wireguard.profiles) != [ ];
    };
    profiles = mkOption {
      description = "Configure wireguard profiles";
      type = types.attrsOf (
        types.submodule {
          options = {

          };
        }
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
  };
}
