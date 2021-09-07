{ config, pkgs, lib, ... }:

{
  imports = [
    ./presets/headful.nix
    ./presets/workstation.nix
  ];

  boot.extraModprobeConfig = ''
    options iwlwifi 11n_disable=1
  '';

  networking = {
    hostName = "aeolus";
    interfaces = {
      enp2s0f0.useDHCP = true;
      enp5s0.useDHCP = true;
      wlp3s0.useDHCP = true;
    };
  };

  console.keyMap = lib.mkForce "us";

  services.xserver = {
    layout = lib.mkForce "us";
    xkbVariant = lib.mkForce "altgr-intl";
    xkbOptions = lib.mkForce "eurosign:e,compose:caps";
  };
  services.printing.browsedConf = ''
    CreateRemoteRawPrinterQueues Yes
    BrowsePoll cups.mpi-klsb.mpg.de:631
  '';

  users.users.lschuetze = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "scanner" "lp" ];
    shell = pkgs.fish;
  };

  system.stateVersion = "21.05";
}
