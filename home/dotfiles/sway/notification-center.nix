{ config, ... }:

let
  stylix = config.stylix;
in
{
  services.swaync = {
    enable = config.wayland.windowManager.sway.enable;
    settings = {

    };
    #style = import ./notification-center.css { inherit stylix; };
  };
}
