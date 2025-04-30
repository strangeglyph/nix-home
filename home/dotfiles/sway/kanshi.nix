{ config, pkgs, lib, ... }:


let
  work-outputs = name: left_mon_id: right_mon_id: {
    name = name;

    outputs = [
      { criteria = left_mon_id;  position = "0,0";    status = "enable"; }
      { criteria = right_mon_id; position = "1920,0"; status = "enable"; }
      { criteria = "eDP-1"; position = "960,1080"; status = "enable"; }
    ];

    exec = [
      "swaymsg 'workspace 2, move workspace to ${left_mon_id}'"
      "swaymsg 'workspace 3, move workspace to ${left_mon_id}'"
      "swaymsg 'workspace 8, move workspace to ${right_mon_id}'"
    ];
  };
in
{
  services.kanshi = {
    enable = config.wayland.windowManager.sway.enable;
    settings = [
      # For some reason the external monitors re-register under different 
      # names when undocking and redocking, so we have multiple entries 
      # for the work setup
      { profile = work-outputs "work1" "DP-4" "DP-5"; }
      { profile = work-outputs "work2" "DP-6" "DP-7"; }
      { 
        profile = {
          name = "mobile";
          outputs = [{
            criteria = "eDP-1";
            position = "0,0";
            status = "enable";
          }];

          exec = [
            "swaymsg 'workspace 2, move workspace to eDP-1'"
            "swaymsg 'workspace 3, move workspace to eDP-1'"
            "swaymsg 'workspace 8, move workspace to eDP-1'"
          ];
        };
      }
      {
        profile = {
          # Might require manual switch with 'kanshictl switch present-hdmi'
          name = "present-hdmi";
          outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
              status = "enable";
            }
            {
              criteria = "HDMI-A-1";
              position = "1920,0";
              status = "enable";
            }
          ];

          exec = [
            "${pkgs.wl-mirror}/bin/wl-present mirror eDP-1 --fullscreen-output HDMI-A-1 --fullscreen"
          ];
        };
      }
    ];
  };
}
