{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.glyph.dm;
  glib = config.glib;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.bibata-cursors ];

    home-manager.users = glib.eachHumanUser (
      name: ucfg: hm-args: {
        home.pointerCursor = {
          enable = true;
          dotIcons.enable = true;
          name = "Bibata-Original-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
          gtk = {
            enable = true;
            size = hm-args.config.home.pointerCursor.size;
          };
        };
      }
    );
  };
}
