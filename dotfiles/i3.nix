{ pkgs, ... }:

let
  mod = "Mod4";
in {
  modifier = "${mod}";
  fonts = [ "Source Code Pro Regular" "FontAwesome 12" ];
  terminal = "${pkgs.termite}/bin/termite";
  menu = "${pkgs.dmenu}/bin/dmenu_run";
  gaps = {
    outer = 0;
    inner = 10;
  };
  bars = [
    {
      fonts = [ "Source Code Pro Regular" "FontAwesome 12" ];
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
    }
  ];
}
