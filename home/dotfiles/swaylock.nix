{ pkgs, lib, ... }:

{
  enable = true;
  package = pkgs.swaylock-effects;
  settings = {
    font = "SauceCodePro Nerd Font";
    font-size = 32;

    screenshots = true;
    fade-in = 5;
    effect-pixelate = 10;
  };
}
