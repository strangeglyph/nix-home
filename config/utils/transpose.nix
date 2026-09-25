{
  lib,
  config,
  nodes,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options.glyph.transpose = mkOption {
    type = types.submodule {
      options = {
        kanidm = mkOption {
          type = types.listOf (
            types.submodule {
              options.sops = mkOption {
                type = types.attrsOf types.anything;
                description = "Sops config to transpose for SSO";
                default = { };
              };
              options.age = mkOption {
                type = types.attrsOf types.anything;
                description = "Agenix config to transpose for SSO";
                default = { };
              };
              options.provision = mkOption {
                type = types.attrsOf types.anything;
                description = "transpose kanidm provision";
                default = { };
              };
              options.provision-extra = mkOption {
                type = types.attrsOf types.anything;
                description = "things to put into kanidm.provision.extraJsonFile";
                default = { };
              };
            }
          );
          default = [ ];
        };
        restic.auth-files = mkOption {
          type = types.listOf (types.attrsOf types.anything);
          description = "age secret to use as dep for the restic-server htpasswd; expects env file with RESTIC_REST_USERNAME and _PASSWORD";
          default = [ ];
        };
        headscale.dns = mkOption {
          type = types.listOf (types.attrsOf types.anything);
          description = "additional headscale dns entries to configure; use with `globals.services.headscale.mkDnsEntry`";
          default = [ ];
        };
        prometheus = {
          scrape = mkOption {
            type = types.listOf (types.attrsOf types.anything);
            description = "additional prometheus scrape targets to configure; use as `services.prometheus.scrapeConfigs`";
            default = [ ];
          };
          rules = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  records = mkOption {
                    type = types.attrsOf types.str;
                    description = "Recording rules, in <name> = <expr> format";
                    default = { };
                  };
                  alerts = mkOption {
                    type = types.attrsOf (
                      types.submodule {
                        freeformType = types.attrsOf types.anything;
                        options = {
                          expr = mkOption {
                            type = types.str;
                            description = "The expression to evaluate for the alert";
                          };
                        };
                      }
                    );
                    description = "Alerting rules";
                    default = { };
                  };
                };
              }
            );
            description = "prometheus rules to configure";
            default = { };
          };
        };
        nginx.virtualHosts = mkOption {
          type = types.attrsOf types.anything;
          description = "additional vhosts to configure on the front-facing nginx";
          default = { };
        };
      };
    };
    description = "config options that should be transposed to a different machine";
    default = { };
  };

  # (attrpath under glyph.transpose) -> [ transpose.type ]
  # n.b. if transpose type is list, need to flatten
  options.glyph.transpose-here = mkOption {
    readOnly = true;
    default =
      attrpath:
      let
        extract = _: nodeconf: lib.attrByPath attrpath { } nodeconf.config.glyph.transpose;
      in
      lib.mapAttrsToList extract nodes;
  };

  options.glyph.transposed = mkOption { type = types.attrsOf types.anything; };

  config.glyph.transposed = {
    prometheus.rules = lib.mkMerge (
      config.glyph.transpose-here [
        "prometheus"
        "rules"
      ]
    );
  };
}
