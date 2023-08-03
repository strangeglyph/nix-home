{ pkgs, lib, ... }:


let
  work-outputs = left: right: {
    outputs = [
      { criteria = left;    position = "0,0";       status = "enable"; }
      { criteria = right;   position = "1920,0";    status = "enable"; }
      { criteria = "eDP-1"; position = "1920,1080"; status = "enable"; }
    ];

    exec = [
      "swaymsg 'workspace 2, move workspace to ${right}'"
      "swaymsg 'workspace 8, move workspace to ${left}'"
    ];
  };
in
{
  enable = true;
  profiles = {
    "work" = work-outputs "DP-4" "DP-5";
    # For some reason the external monitors re-register under different names
    # when undocking and redocking, so we have multiple entries for the work
    # setup
    "work2" = work-outputs "DP-6" "DP-7";

    "mobile" = {
      outputs = [{
        criteria = "eDP-1";
        position = "0,0";
        status = "enable";
      }];

      exec = [
        "swaymsg 'workspace 2, move workspace to eDP-1'"
        "swaymsg 'workspace 8, move workspace to eDP-1'"
      ];
    };
  };
}
