{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.glyph.dm.portal;
in
{
  imports = [
    ./nemo.nix
  ];

  options.glyph.dm.portal = {
    enable = mkOption {
      description = "Enable desktop portal";
      default = config.glyph.dm.enable;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services = {
      dbus = {
        apparmor = "enabled";
        implementation = "broker";
      };

      gnome.gnome-keyring.enable = true;

      xserver.desktopManager.runXdgAutostartIfNone = true;
    };

    security.soteria.enable = true; # polkit agent

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
