{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (config) glib;
  cfg = config.glyph.dm.sway;

  theme = config.glyph.theme;
  scheme = theme.color.schemes.${theme.color.sway};
  fonts = theme.fonts;
  inherit (scheme.mnemonics) background category;
  inherit (glib.color) strip;
in
{
  config = mkIf cfg.enable {
    security.pam.services.swaylock.text = ''
      auth include login
    '';

    home-manager.users = glib.eachHumanUser' (name: {
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          font = fonts.monospace.name;
          font-size = 32;

          screenshots = true;
          fade-in = 1;
          effect-pixelate = 8;
          grace = 5;
          clock = true;
          datestr = "%a, %d. %b %Y";
          indicator = true;
          indicator-radius = 120;
          inside-color = "${strip background.main}7f";
          key-hl-color = "${strip category.accent}";
          bs-hl-color = "${category.alert}";
          ring-color = "${strip category.accent}7f";
          text-color = "${strip category.accent}";

          inside-clear-color = "${strip category.accent}7f";
          ring-clear-color = "${strip category.accent}";
          text-clear-color = "${strip background.main}";

          inside-ver-color = "${strip category.focus}7f";
          ring-ver-color = "${strip category.focus}";
          text-ver-color = "${strip background.main}";

          inside-wrong-color = "${strip category.error}7f";
          ring-wrong-color = "${strip category.error}";
          text-wrong-color = "${strip background.main}";

          line-color = "00000000";
          line-clear-color = "00000000";
          separator-color = "00000000";
        };
      };
    });
  };
}
