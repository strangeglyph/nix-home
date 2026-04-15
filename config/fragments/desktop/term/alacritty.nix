{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (config) glib;
  fonts = config.glyph.theme.fonts;
in
{
  options.glyph.users = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          term = lib.mkOption {
            default = "alacritty";
            type = types.enum [ "alacritty" ];
          };
        };
      }
    );
  };

  config = {
    home-manager.users = glib.eachHumanUser (
      name: cfg: {
        programs.alacritty = {
          enable = config.glyph.dm.enable && cfg.term == "alacritty";
          settings = {
            font = {
              normal.family = fonts.monospace.name;
              size = fonts.sizes.terminal;
            };
            window = {
              opacity = 0.8;
              blur = true;
              padding = {
                x = 5;
                y = 5;
              };
              dynamic_padding = true;
            };
          };
        };
      }
    );
  };
}
