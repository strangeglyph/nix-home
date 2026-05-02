{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  g_nginx = config.globals.services.nginx;
in
{
  options.glyph.syncproxy.enable = mkEnableOption "Syncademy development proxy";

  config = mkIf config.glyph.syncproxy.enable {
    services.nginx = {
      enable = true;
      virtualHosts."sync.apophenic.net" = g_nginx.mkReverseProxy {
        domain = "rosetta.interstice.apophenic.net";
        port = "19352";
      };
    };
  };
}
