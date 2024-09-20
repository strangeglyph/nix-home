# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
let
  lix = fetchGit {
    url = "git@git.lix.systems:lix-project/lix.git";
    ref = "main";
    # Pin to keep rebuilds fast, update irregularly
    rev = "79246a37337c5df2224dbc2461c722e1e678f6de";
  };
  lix-module = fetchGit {
    url = "git@git.lix.systems:lix-project/nixos-module.git";
    ref = "main";
    # Do not pin, keep up to date
    #rev = "b0e6f359500d66670cc16f521e4f62d6a0a4864e";
  };
  lix-overlay = import "${lix-module}/overlay.nix" { inherit lix; };
in

{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [ lix-overlay ];

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

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
    };
    optimise = {
      automatic = true;
    };
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
    ethtool socat
    glib gcc binutils gnumake
    parted
    wget curl ncurses which git htop lsof pv ripgrep eza file jq
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

