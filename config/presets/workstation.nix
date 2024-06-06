{ config, pkgs, lib, ... }:

{
  networking.networkmanager.enable = true;

  hardware.sane.enable = true;
  hardware.opengl.enable = true;

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
    udisks2.enable = true;
  };

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    keepassxc
    cups
    brightnessctl
  ];
}
