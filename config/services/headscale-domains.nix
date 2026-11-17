{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  inherit (config) glib;
  gservices = config.globals.services;
  gheadscale = gservices.headscale;
  domains = config.glyph.vpn.domains;
in
{
  options.glyph.vpn.domains = mkOption {
    description = "Point the domains listed here to this host via VPN";
    type = types.attrsOf (
      types.submodule (
        { ... }:
        {
          options = {
            nginx.enable = mkOption {
              type = types.bool;
              default = true;
            };
            nginx.upstream_port = mkOption { type = types.port; };
            nginx.extraConfig = mkOption { default = { }; };
          };
        }
      )
    );
    default = { };
  };

  config =
    mkIf
      (glib.anyEnables [
        "glyph"
        "headscale"
      ])
      {
        security.acme.certs = lib.mapAttrs' (
          name: _: lib.nameValuePair (gheadscale.mkSub name) { group = "nginx"; }
        ) domains;

        services.nginx.virtualHosts = lib.mapAttrs' (
          name: cfg:
          lib.nameValuePair (gheadscale.mkSub name) (
            mkIf (cfg.nginx.enable) (
              lib.mkMerge [
                (gservices.nginx.mkReverseProxy {
                  proto = "http";
                  domain = "127.0.0.1";
                  port = cfg.nginx.upstream_port;
                  acme_host = gheadscale.mkSub name;
                  listen = [ gheadscale.myAddr ];
                })
                cfg.nginx.extraConfig
              ]
            )
          )
        ) domains;

        glyph.transpose.headscale.dns = lib.map gheadscale.mkDnsEntry (lib.attrNames domains);
      };
}
