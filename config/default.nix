# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
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
    xserver = {
      enable = true;
      layout = "de";
      xkbVariant = "deadacute";
      xkbOptions = "compose:caps";
      libinput.enable = true;

      windowManager.i3 =  {
          enable = true;
          package = pkgs.i3-gaps;
      };

      displayManager = {
        lightdm.enable = true;
        defaultSession = "none+i3";
      };
    };
    compton = {
      enable = true;
      shadow = true;
      inactiveOpacity = 0.8;
      menuOpacity = 1.0;
    };
  };


  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };


  users.users = {
    root = {
      shell = pkgs.fish;
    };
  };


  security.sudo.extraConfig = "Defaults timestamp_timeout=30";


  programs = {
    light.enable = true;
    vim.defaultEditor = true;
    nano.nanorc = ''
      set tabsize 4
      set tabstospaces
    '';
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableSSHSupport = true;
    };
    mtr.enable = true;
    fish.enable = true;
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [
      "Noto"
      "SourceCodePro"
      "DejaVuSansMono"
                          ]; })
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    cantarell-fonts
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      "Noto Sans Nerd Font"
      "Noto Color Emoji"
      "Noto Emoji"
    ];
    serif = [
      "Noto Serif Nerd Font"
      "Noto Color Emoji"
      "Noto Emoji"
    ];
    monospace = [
      "SauceCodePro Nerd Font"
      "Noto Color Emoji"
      "Noto Emoji"
    ];
    emoji = [
      "Noto Color Emoji"
      "Noto Emoji"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = let
    moz-rev = "master";
    moz-nix = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${moz-rev}.tar.gz"; };
    ff-nightly-overlay = import "${moz-nix}/firefox-overlay.nix";
  in [
    ff-nightly-overlay
  ];

  environment.systemPackages = with pkgs;
  let
    basic-python-install = python3.withPackages (python-packages: with python-packages; [
      pip wheel virtualenv
    ]);
    agda-with-stdlib = agda.withPackages (agda-packages: with agda-packages; [
      standard-library
    ]);
  in [
    xorg.xinit xorg.libX11 xorg.libXext xorg.libXrender xorg.libICE xorg.libSM 
    xorg.xmodmap xsel
    libnotify
    glib gcc binutils gnumake
    parted
    wget curl ncurses which git htop lsof pv ripgrep exa file
    zip unzip
    alacritty
    vim emacs
    latest.firefox-nightly-bin
    thunderbird
    zathura
    basic-python-install
    pipenv
    texlive.combined.scheme-full haskellPackages.lhs2tex
    agda-with-stdlib
    ghc
    inotify-tools
    feh scrot imgur-screenshot
  ];

  environment.sessionVariables = {
    TERMINAL = [ "alacritty" ];
  };

  system.copySystemConfiguration = true;
}

