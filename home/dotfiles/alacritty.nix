{ pkgs, ... }:

{
  enable = true;
  settings = {
    opacity = 0.8;
    font = {
      normal.family = "SauceCodePro Nerd Font";
      size = 12.0;
    };
    window = {
      padding = {
        x = 5;
        y = 5;
      };
      dynamic_padding = true;
    };
  };
}
