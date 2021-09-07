{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      enable = true;
      layout = "de";
      xkbVariant = "deadacute";
      xkbOptions = "compose:caps";
      libinput.enable = true;

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = [ pkgs.i3lock ];
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

  programs = {
    light.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Noto" "SourceCodePro" "DejaVuSansMono" ]; })
    noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
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

  nixpkgs.overlays = let
    moz-overlays = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz"; };
    ff-nightly-overlay = import "${moz-overlays}/firefox-overlay.nix";
  in [
    ff-nightly-overlay
  ];

  environment.systemPackages = with pkgs; let
    agda-with-stdlib = agda.withPackages (agda-packages: [ agda-packages.standard-library ]);
  in [
    xorg.xinit xorg.libX11 xorg.libXext xorg.libXrender xorg.libICE xorg.libSM
    xorg.xmodmap xsel
    libnotify
    alacritty
    latest.firefox-nightly-bin
    thunderbird
    zathura
    texlive.combined.scheme-full
    haskellPackages.lhs2tex
    agda-with-stdlib
    feh
    scrot
    imgur-screenshot
    gnome.networkmanagerapplet
    libreoffice
  ];

  environment.sessionVariables = {
    TERMINAL = [ "alacritty" ];
  };
}
