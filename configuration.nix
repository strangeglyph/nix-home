# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "mei_wdt" ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
      useDHCP = false;
      hostName = "euclid";

      interfaces.enp0s3.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  virtualisation.virtualbox.guest.enable = true;

  # Enable the X11 windowing system.
  services = {
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
        autoLogin.enable = true;
        autoLogin.user = "glyph";
        defaultSession = "none+i3";
      };
    };
    mingetty.autologinUser = "glyph";
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
    glyph = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.fish;
    };
  };


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
    font-awesome-ttf
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    dejavu_fonts
    powerline-fonts
    source-code-pro
    cantarell-fonts
  ];

  environment.systemPackages = with pkgs; 
  let
    basic-python-install = python3.withPackages (python-packages: with python-packages; [
      pip wheel virtualenv
    ]);
  in [
    xorg.xinit xorg.libX11 xorg.libXext xorg.libXrender xorg.libICE xorg.libSM xsel
    glib gcc binutils gnumake
    parted
    wget curl ncurses which git htop lsof pv ripgrep exa
    zip unzip
    termite
    vim emacs
    firefox
    zathura
    basic-python-install
    pipenv
    texlive.combined.scheme-medium
  ];

  environment.sessionVariables = {
    TERMINAL = [ "termite" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  system.copySystemConfiguration = true;
}

