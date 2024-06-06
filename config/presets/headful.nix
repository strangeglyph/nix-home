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
        lightdm.enable = false; # For sway, use greetd below
        defaultSession = "none+i3";
      };
    };

    greetd = {
      enable = true; # For i3, use displayManager.lightdm above
      settings = {
        default_session = {
          command = "${pkgs.greetd.greetd}/bin/agreety --cmd sway";
        };
      };
    };

    compton = {
      enable = true;
      shadow = true;
      inactiveOpacity = 0.8;
      menuOpacity = 1.0;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };


  security.rtkit.enable = true;

  programs = {
    light.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };
    firefox = {
      enable = true;
      # package = pkgs.latest.firefox-nightly-bin;
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Noto" "SourceCodePro" "DejaVuSansMono" ]; })
    noto-fonts-cjk noto-fonts-color-emoji noto-fonts-extra
    cantarell-fonts
    liberation_ttf
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
    agda-with-stdlib = agda.withPackages (agda-packages: [ 
      agda-packages.standard-library 
    ]);
  in [
    xorg.xinit xorg.libX11 xorg.libXext xorg.libXrender xorg.libICE xorg.libSM
    xorg.xmodmap xsel xorg.xbacklight
    arandr
    libnotify
    alacritty
    thunderbird
    zathura pdfpc
    xournalpp
    texlive.combined.scheme-full
    texstudio
    haskellPackages.lhs2tex
    agda-with-stdlib
    feh
    scrot
    imgur-screenshot
    playerctl
    networkmanagerapplet
    libreoffice
    mendeley
    zoom-us
    pulseaudio # for pactl (https://nixos.wiki/wiki/PipeWire#Troubleshooting)
    deadd-notification-center
  ];

  environment.sessionVariables = {
    TERMINAL = [ "alacritty" ];
  };
}
