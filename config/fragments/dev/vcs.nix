{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types mkIf;
  glib = config.glib;
  cfg = config.glyph.dev.git;
in
{
  options.glyph.dev = {
    git = {
      configure = mkOption {
        description = "Configure common git settings";
        default = true;
        type = types.bool;
      };
      configure-personal = mkOption {
        description = "Configure personal git information";
        default = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.configure {
    home-manager.users = glib.eachHumanUser (
      name: _: {
        programs.git.settings = {
          user = mkIf cfg.configure-personal {
            name = "glyph";
            email = config.glyph.confidentials.email.git;
          };
        };
      }
    );
  };
}
