{
  config,
  lib,
  ...
}:
let
  inherit (config) glib;
  inherit (glib) mkRo;

in
{
  options.glib = lib.mkOption {
    type = lib.types.submodule {
      options.kdl = {
        assertions = {

        };
      };
    };
  };
}
