{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./boot.nix
    ./printer.nix
    ./backup.nix
    ./network
  ];

  config = {
    # Faster shutdown
    systemd.settings.Manager.DefaultTimeoutStopSec = "15s";
    systemd.user.extraConfig = "DefaultTimeoutStopSec=15s";

    # Set your time zone.
    time.timeZone = mkDefault "Europe/Berlin";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];

    services = {
      fstrim.enable = true;
      lorri.enable = true;
    };
  };
}
