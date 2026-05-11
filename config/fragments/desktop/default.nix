{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.glyph.dm;
in
{
  imports = [
    ./networkmanager.nix
    ./sound.nix
    ./power.nix
    ./wallpapers.nix
    ./sway
    ./niri
    ./term
  ];

  options.glyph.dm = {
    enable = mkOption {
      description = "Set up a graphic desktop environment";
      type = lib.types.bool;
      default = true;
    };
    default-wm = mkOption {
      description = "Default window manager to start for graphical sessions";
      type = types.enum [ ];
    };
  };

  config = mkIf cfg.enable {
    services = {
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
          banner = "Once more unto the breach";
        };
        defaultSession = cfg.default-wm;
      };

      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
        touchpad.disableWhileTyping = true;
      };
    };

    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        table
        table-others
      ];
    };

    # Backlight control
    programs.light.enable = true;

    # Bluetooth
    hardware.bluetooth.enable = true;

    environment.systemPackages = with pkgs; [
      # Screen mirroring for presentations
      wl-mirror

      thunderbird
      inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin

      # password safe
      bitwarden-desktop

      # terminal
      alacritty
    ];

    environment.sessionVariables = {
      TERMINAL = [ "alacritty" ];
    };
  };
}
