# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
all@{ config, pkgs, lib, inputs, system, ... }:
{
  imports = [
    ./presets/theme.nix
  ];

  _module.args = { 
    globals = import ./utils/globals.nix all;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.nameservers = [ "9.9.9.9" "1.1.1.1" ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ 
    "C.UTF-8/UTF-8" 
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8" 
  ];
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };


  services = {
    fstrim.enable = true;
    lorri.enable = true;
    resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "opportunistic";
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = { inherit inputs system; };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      #deprecated-features = url-literals
    '';
    gc = {
      automatic = true;
      dates = "weekly";
    };
    optimise = {
      automatic = true;
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  users.users = {
    root = {
      shell = pkgs.fish;
    };
  };


  security.sudo.extraConfig = "Defaults timestamp_timeout=30";
  security.polkit.enable = true;
  security.pam.services.swaylock.text = ''
    auth include login
  '';

  programs = {
    vim.enable = true;
    vim.defaultEditor = true;
    nano.nanorc = ''
      set tabsize 4
      set tabstospaces
    '';
    mtr.enable = true;
    fish.enable = true;
    ssh.startAgent = true;
    dconf.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
  ];

  environment.systemPackages = with pkgs;
  let
    basic-python-install = python3.withPackages (python-packages: with python-packages; [
      pip wheel virtualenv
    ]);
  in [
    pciutils lshw wirelesstools
    ethtool socat dig
    wireguard-tools
    glib gcc binutils gnumake
    parted
    wget curl 
    ncurses which 
    git jujutsu
    htop lsof pv ripgrep eza file jq
    zip unzip
    vim emacs
    basic-python-install
    pipenv
    ghc
    inotify-tools
    screen
    direnv
  ];
}

