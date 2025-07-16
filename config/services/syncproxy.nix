all@{ config, lib, ... }:
let
  g_nginx = config.globals.services.nginx;
in
{
  config.services.nginx = {
    enable = true;
    virtualHosts."sync.apophenic.net" = g_nginx.mkReverseProxy {
      domain = "rosetta.interstice.apophenic.net";
      port = "19352";
    };
  };
}
