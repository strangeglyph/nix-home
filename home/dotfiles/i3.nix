{ pkgs, ... }:

let
  mod = "Mod4";
in {
  modifier = "${mod}";
  defaultWorkspace = "workspace number 1";
  fonts = {
    names = [ "FontAwesome" "Source Code Pro" ];
    size = 12.0;
  };

  terminal = "${pkgs.termite}/bin/termite";
  menu = "${pkgs.dmenu}/bin/dmenu_run";
  gaps = {
    outer = 0;
    inner = 10;
  };
  bars = [
    {
      fonts = {
        names = [ "FontAwesome" "Source Code Pro" ];
        size = 12.0;
      };
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
    }
  ];
}