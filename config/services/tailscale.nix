{ config, lib, pkgs, ... }:
let
  tailscale = config.services.tailscale;
in
{
  config = {
    services.tailscale = {
      useRoutingFeatures = "both";
      openFirewall = true;
      extraUpFlags = [
        "--login-server=https://ouroboros.apophenic.net"
      ];
    };
  };
}
