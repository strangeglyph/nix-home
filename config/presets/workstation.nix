{ config, pkgs, lib, ... }:

{
  networking.networkmanager.enable = true;

  hardware.sane.enable = true;

  services = {
    xserver.libinput.touchpad.naturalScrolling = true;
    xserver.libinput.touchpad.disableWhileTyping = true;
    xserver.wacom.enable = true;

    acpid.enable = true;
    logind.extraConfig = "HandlePowerKey=suspend";
    printing = {
      enable = true;
      drivers = with pkgs; [ 
        gutenprint
        gutenprintBin
        epson-escpr
      ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
    };
  };

  environment.systemPackages = with pkgs; let
    keepassWithRpc = keepass.override { plugins = [ keepass-keepassrpc ]; };
  in [
    keepassWithRpc
    cups
  ];
}
