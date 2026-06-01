{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (config) glib;
  lock-with-effects = "${pkgs.swaylock-effects}/bin/swaylock -f";
in
{
  config = mkIf (config.glyph.dm.default-wm == "sway") {
    home-manager.users = glib.eachHumanUser' (name: {
      services.swayidle = {
        enable = true;
        events = {
          before-sleep = lock-with-effects;
        };
        timeouts = [
          {
            timeout = 300;
            command = lock-with-effects;
          }
        ];
      };
    });
  };
}
