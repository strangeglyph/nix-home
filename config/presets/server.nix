{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [
    443 # quic
  ];

  services = {
    openssh = {
      enable = true;
    };
  };
}
