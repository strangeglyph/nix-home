{ lib, config, name, nodes, ... }:
let
  inherit (lib) mkOption mkMerge mkIf types;
in
{
  options.glyph.transpose = mkOption {
    type = types.submodule ({    
      options.kanidm = mkOption {
        type = types.listOf (types.submodule {
          options.age = mkOption { type = types.attrsOf types.anything; description = "Age config to transpose for SSO"; default = {}; };
          options.provision = mkOption { type = types.attrsOf types.anything; description = "kanidm service provision"; default = {}; };
        });
        default = [];
      };
    });
    description = "config options that should be transposed to a different machine";
    default = {};
  };

  options.glyph.transpose-here = mkOption {
    readOnly = true;
    default = attrpath:
      let
        extract = _: nodeconf: lib.attrByPath attrpath {} nodeconf.config.glyph.transpose;
      in
        lib.mapAttrsToList extract nodes;
  };
}
