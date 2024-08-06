{ pkgs, ... }:

{
  enable = true;
  settings = {
    font = {
      normal.family = "SauceCodePro Nerd Font";
      size = 12.0;
    };
    window = {
      opacity = 0.8;
      blur = true;
      padding = {
        x = 5;
        y = 5;
      };
      dynamic_padding = true;
    };
  };
}
