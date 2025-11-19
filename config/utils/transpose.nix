{ lib, config, name, nodes, ... }:
let
  inherit (lib) mkOption mkMerge mkIf types;
in
{
  options.glyph.transpose = mkOption {
    type = types.submodule ({    
      options = {
        kanidm = mkOption {
          type = types.listOf (types.submodule {
            options.age = mkOption { type = types.attrsOf types.anything; description = "Age config to transpose for SSO"; default = {}; };
            options.provision = mkOption { type = types.attrsOf types.anything; description = "transpose kanidm provision"; default = {}; };
            options.provision-extra = mkOption { type = types.attrsOf types.anything; description = "things to put into kanidm.provision.extraJsonFile"; default = {}; };
          });
          default = [];
        };
        restic.auth-files = mkOption {
          type = types.listOf (types.attrsOf types.anything);
          description = "age secret to use as dep for the restic-server htpasswd; expects env file with RESTIC_REST_USERNAME and _PASSWORD";
          default = [];
        };
        headscale.dns = mkOption {
          type = types.listOf (types.attrsOf types.anything);
          description = "additional headscale dns entries to configure; use with `globals.services.headscale.mkDnsEntry`";
          default = [];
        };
      };
    });
    description = "config options that should be transposed to a different machine";
    default = {};
  };

  # (attrpath under glyph.transpose) -> [ transpose.type ]
  # n.b. if transpose type is list, need to flatten
  options.glyph.transpose-here = mkOption {
    readOnly = true;
    default = attrpath:
      let
        extract = _: nodeconf: lib.attrByPath attrpath {} nodeconf.config.glyph.transpose;
      in
        lib.mapAttrsToList extract nodes;
  };
}
