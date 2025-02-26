{ config, pkgs, lib, ... }:

{
  imports = [
    ./presets/headful.nix
    ./presets/workstation.nix
  ];

  # boot.extraModprobeConfig = ''
  #  options iwlwifi 11n_disable=8
  #  options iwlwifi power_save=0
  #   options iwlmvm  power_scheme=1
  #'';

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
    xkb.layout = lib.mkForce "us";
    xkb.variant = lib.mkForce "altgr-intl";
    xkb.options = lib.mkForce "eurosign:e,compose:caps";
  };
  services.printing.browsedConf = ''
    CreateRemoteRawPrinterQueues Yes
    BrowsePoll cups.mpi-klsb.mpg.de:631
  '';

  users.users.lschuetze = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel"
      "networkmanager"
      "scanner"
      "lp"
      "wireshark"
      "audio"
      "video"
      "input"
    ];
    shell = pkgs.fish;
  };
  home-manager.users.root.imports = [ ../home/aeolus/root.nix ];
  home-manager.users.lschuetze.imports = [ ../home/aeolus/lschuetze.nix ];

  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    openscad
    prusa-slicer
  ];

  system.stateVersion = "21.05";
}
