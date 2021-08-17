{ config, pkgs, lib, ... }:

{
  networking = {
    hostName = "aeolus";
    interfaces = {
      enp2s0f0.useDHCP = true;
      enp5s0.useDHCP = true;
      wlp3s0.useDHCP = true;
    };
    networkmanager.enable = true;
  };

  console.keyMap = lib.mkForce "us";

  services.xserver = {
    layout = lib.mkForce "us";
    xkbVariant = lib.mkForce "altgr-intl";
    xkbOptions = lib.mkForce "eurosign:e,compose:caps";
    libinput.naturalScrolling = true;
  };

  users.users.lschuetze = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  system.stateVersion = "21.05";
}
