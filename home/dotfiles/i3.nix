{ pkgs, ... }:

let
  mod = "Mod4";
in {
  modifier = "${mod}";
  defaultWorkspace = "workspace number 1";
  fonts = {
    names = [ "SauceCodePro Nerd Font" ];
    size = 12.0;
  };

  terminal = "${pkgs.alacritty}/bin/alacritty";
  menu = "${pkgs.dmenu}/bin/dmenu_run";
  gaps = {
    outer = 0;
    inner = 10;
  };
  floating = {
    criteria = [
      { class = "KeePass2"; }
      { class = "floatingTerm"; }
    ];
  };
  bars = [
    {
      fonts = {
        names = [ "SauceCodePro Nerd Font" ];
        size = 12.0;
      };
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
    }
  ];
}
