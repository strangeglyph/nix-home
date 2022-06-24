{ config, pkgs, lib, ... }:

{
  imports = [
    ./presets/headful.nix
    ./presets/workstation.nix
  ];

  boot.extraModprobeConfig = ''
    options iwlwifi 11n_disable=8
    options iwlwifi power_save=0
    options iwlmvm  power_scheme=1
  '';

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

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
    extraGroups = [ "wheel" "networkmanager" "scanner" "lp" "wireshark" ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
  ];

  system.stateVersion = "21.05";
}
