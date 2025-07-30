{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./theme.nix
  ];

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

    gnome.core-apps.enable = false;

    # Only applies if xserver.displayManager.lightdm.enable = true (above)
    displayManager = {
      # defaultSession = "none+i3";
      # defaultSession = "gnome";
      defaultSession = "sway";
    };

    pulseaudio.enable = false;

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

    #pam.services.hyprlock = {};
  };


  security.rtkit.enable = true;

  programs = {
    light.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };
    # nb. main sway/hyprland config is in home-manager
    sway.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.noto
    nerd-fonts.sauce-code-pro
    nerd-fonts.dejavu-sans-mono
    noto-fonts-cjk-sans noto-fonts-color-emoji noto-fonts-extra
    cantarell-fonts
    liberation_ttf
    lmodern
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      "NotoSans Nerd Font"
      "Noto Color Emoji"
      "Noto Emoji"
    ];
    serif = [
      "NotoSerif Nerd Font"
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

  environment.systemPackages = with pkgs; [
    xorg.xinit xorg.libX11 xorg.libXext xorg.libXrender xorg.libICE xorg.libSM
    xorg.xmodmap xsel xorg.xbacklight
    wev
    arandr
    libnotify
    alacritty
    thunderbird
    zathura pdfpc evince
    xournalpp
    texlive.combined.scheme-full
    texstudio
    imgur-screenshot
    playerctl
    networkmanagerapplet
    libreoffice
    zoom-us
    pulseaudio # for pactl (https://nixos.wiki/wiki/PipeWire#Troubleshooting)
    wl-mirror
    bitwarden-desktop
    inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
  ];

  environment.sessionVariables = {
    TERMINAL = [ "alacritty" ];
  };
}
