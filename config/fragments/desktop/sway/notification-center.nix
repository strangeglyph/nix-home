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

      systemd.user.services.swaync.Unit.PartOf = lib.mkForce [ "sway-session.target" ];
    });
  };
}
