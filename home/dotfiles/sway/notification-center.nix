{ config, ... }:

let
  stylix = config.stylix;
in
{
  services.swaync = {
    enable = true;
    settings = {

    };
    #style = import ./notification-center.css { inherit stylix; };
  };
}
