{ pkgs, lib, ... }:

{
  enable = true;
  profiles = {
    "work" = {
      # Two big monitors horizontal, laptop monitor below right
      outputs = [
        {
          criteria = "DP-4";
          position = "0,0";
          status = "enable";
        }
        {
          criteria = "DP-5";
          position = "1920,0";
          status = "enable";
        }
        {
          criteria = "eDP-1";
          position = "1920,1080";
          status = "enable";
        }
      ];

      exec = [
        "workspace 2, move workspace to DP-5"
        "workspace 8, move workspace to DP-4"
      ];
    };

    "mobile" = {
      outputs = [{
        criteria = "eDP-1";
        position = "0,0";
        status = "enable";
      }];
    };
  };
}
