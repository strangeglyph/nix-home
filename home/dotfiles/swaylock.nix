{ pkgs, lib, ... }:

{
  enable = true;
  package = pkgs.swaylock-effects;
  settings = {
    font = "SauceCodePro Nerd Font";
    font-size = 32;

    screenshots = true;
    fade-in = 1;
    effect-pixelate = 8;
  };
}
