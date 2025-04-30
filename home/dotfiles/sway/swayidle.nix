{ config, pkgs, ... }:
let
  lock-with-effects = "${pkgs.swaylock-effects}/bin/swaylock -f";
in
{
  services.swayidle = {
    enable = config.wayland.windowManager.sway.enable;
    events = [
      { event = "before-sleep"; command = lock-with-effects; }
    ];
    timeouts = [
      { timeout = 300; command = lock-with-effects; }
    ];
  };
}
