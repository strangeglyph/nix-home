{ lib, config, ... }:
let
  inherit (lib) mkIf;
  inherit (config) glib;
in
{
  config = mkIf (config.glyph.dm.default-wm == "sway") {
    home-manager.users = glib.eachHumanUser' (name: {
      services.swaync = {
        enable = true;
      };
    });
  };
}
