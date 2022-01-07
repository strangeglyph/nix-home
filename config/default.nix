# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };


  services = {
    fstrim.enable = true;
    lorri.enable = true;
  };

  users.users = {
    root = {
      shell = pkgs.fish;
    };
  };


  security.sudo.extraConfig = "Defaults timestamp_timeout=30";


  programs = {
    vim.defaultEditor = true;
    nano.nanorc = ''
      set tabsize 4
      set tabstospaces
    '';
    mtr.enable = true;
    fish.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs;
  let
    basic-python-install = python3.withPackages (python-packages: with python-packages; [
      pip wheel virtualenv
    ]);
  in [
    pciutils lshw wirelesstools
    glib gcc binutils gnumake
    parted
    wget curl ncurses which git htop lsof pv ripgrep exa file jq
    zip unzip
    vim emacs
    basic-python-install
    pipenv
    ghc
    inotify-tools
    screen
    direnv
  ];

  system.copySystemConfiguration = true;
}

