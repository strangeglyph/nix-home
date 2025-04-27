{ pkgs, ... }:
let
  lock-with-effects = "${pkgs.swaylock-effects}/bin/swaylock -f";
in
{
  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = lock-with-effects; }
    ];
    timeouts = [
      { timeout = 300; command = lock-with-effects; }
    ];
  };
}
