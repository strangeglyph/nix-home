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
    ./portal.nix
    ./cursor.nix
    ./sway
    ./niri
    ./term
  ];

  options.glyph.dm = {
    enable = mkOption {
      description = "Set up a graphic desktop environment";
      type = lib.types.bool;
      default = false;
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

    # Bluetooth
    hardware.bluetooth.enable = true;

    programs.firefox = {
      enable = true;
      package = inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;
      preferences = {
        "browser.tabs.allow_transparent_browser" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };

      #userChrome = builtins.readFile ./assets/userChrome.css;
      #userContent = builtins.readFile ./assets/userContent.css;
    };

    environment.systemPackages = with pkgs; [
      # Screen mirroring for presentations
      wl-mirror

      thunderbird

      # password safe
      # (bitwarden-desktop currently relies on an EOL electron version https://github.com/bitwarden/clients/pull/20448)
      # bitwarden-desktop

      # terminal
      alacritty
    ];

    environment.sessionVariables = {
      TERMINAL = [ "alacritty" ];
    };
  };
}
