{ pkgs, lib, ... }:

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
  assigns = {
    "8" = [{ class = "(?i)firefox"; }];
    "9" = [{ class = "(?i)thunderbird"; }];
  };
  workspaceOutputAssign = [
    { workspace = "8"; output = "DisplayPort-2"; }
    { workspace = "9"; output = "DisplayPort-2"; }
  ];
  # Fitting for gruvbox-dark
  # currently disabled as colors cannot be set individually
  #colors = {
  #  focused.border = "#d65d0e";
  #  focusedInactive.border = "#fe8019";
  #  unfocused.border = "#fe8019";
  #  urgent.border = "#cc241d";
  #};
  floating = {
    criteria = [
      { class = "KeePass2"; }
      { class = "floatingTerm"; }
    ];
  };
  startup = [
    { command = "firefox"; }
    { command = "thunderbird"; }
    { command = "alacritty"; workspace = "1"; }
  ];
  keybindings = lib.mkOptionDefault {
    "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
    "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
    "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
    "XF86MonBrightnessUp" = "exec xbacklight -inc 20";
    "XF86MonBrightnessDown" = "exec xbacklight -dec 20";
    "XF86AudioPlay"  = "exec playerctl play";
    "XF86AudioPause" = "exec playerctl pause";
    "XF86AudioNext" = "exec playerctl next";
    "XF86AudioPrev" = "exec playerctl previous";
  };

  bars = [
    {
      fonts = {
        names = [ "SauceCodePro Nerd Font" ];
        size = 12.0;
      };
      # Fitting for gruvbox-dark
      colors = {
        focusedBackground = "#282828";
        activeWorkspace = "#98971a";
        inactiveWorkspace = "#282828";
        urgentWorkspace = "#cc241d";
      };
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
    }
  ];
}
