{ config, pkgs, lib, inputs, ... }:

{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "de";
      xkb.variant = "deadacute";
      xkb.options = "compose:caps";

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = [ pkgs.i3lock ];
      };

      displayManager = {
        lightdm.enable = false; # For sway, use greetd below
        gdm = {
          enable = true;
          wayland = true;
        };
      };
      desktopManager.gnome.enable = true;
    };

    gnome.core-utilities.enable = false;

    # Only applies if xserver.displayManager.lightdm.enable = true (above)
    displayManager = {
      # defaultSession = "none+i3";
      # defaultSession = "gnome";
      defaultSession = "sway";
    };


    libinput.enable = true;

    greetd = {
      enable = false; # For i3, use displayManager.lightdm above
      settings = {
        default_session = {
          command = "${pkgs.greetd.greetd}/bin/agreety --cmd sway";
        };
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  programs = {
    light.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };
    # Replaced by flake?
    #firefox = {
    #  enable = true;
      # package = pkgs.latest.firefox-nightly-bin;
    #};
    sway.enable = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Noto" "SourceCodePro" "DejaVuSansMono" ]; })
    noto-fonts-cjk-sans noto-fonts-color-emoji noto-fonts-extra
    cantarell-fonts
    liberation_ttf
    lmodern
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

  #environment.gnome.excludePackages = (with pkgs; [
  #  gnome-tour
  #  gnome-connections
  #]) ++ (with pkgs.gnome; [
  #  geary
  #  epiphany
  #]);

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
    zathura pdfpc evince
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
    wl-mirror
    inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
  ];

  environment.sessionVariables = {
    TERMINAL = [ "alacritty" ];
  };
}
