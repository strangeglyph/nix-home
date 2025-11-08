{ config, pkgs, lib, ... }:

{
  imports = [
    ./presets/headful.nix
    ./presets/workstation.nix
    ./services/tailscale.nix
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
      #enp2s0f0.useDHCP = true;
      #enp5s0.useDHCP = true;
      #wlp3s0.useDHCP = true;
    };
  };

  age.secrets.wg-rptu.file = ../secrets/sources/wg-rptu-split-aeolus.age;
  #networking.wg-quick.interfaces.wg-rptu.configFile = config.age.secrets.wg-rptu.path;

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
  services.openssh = {
    enable = true; # just so we give agenix something to work with
    openFirewall = false; # but we don't really want to expose it
  };

  systemd.extraConfig = "DefaultTimeoutStopSec=15s";
  systemd.user.extraConfig = "DefaultTimeoutStopSec=15s";

  services.tailscale.enable = true;

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
    jetbrains.pycharm-professional
    poetry
    openscad
    prusa-slicer
    obsidian
    (agda.withPackages [ agdaPackages.standard-library ])
    vscode-fhs
    inkscape-with-extensions
  ];

  system.stateVersion = "21.05";
}
