{ pkgs, ... }:
{
  enable = true;

  allowBold = true;
  clickableUrl = true;
  dynamicTitle = true;
  scrollOnOutput = true;
  scrollOnKeystroke = true;
  urgentOnBell = true;

  font = "Source Code Pro Regular 11";

  browser = "${pkgs.firefox}/bin/firefox";

  cursorBlink = "on";
  cursorShape = "block";

  sizeHints = true;
  scrollbar = "off";

  backgroundColor = "rgba(7, 54, 66, 0.6)";
  cursorColor = "#eee8d5";
  foregroundColor = "#eee8d5";
  foregroundBoldColor = "#eee8d5";
  highlightColor = "#eee8d5";

  colorsExtra = ''
     # Solarized colors
     # black
     color0 = #073642
     color8 = #002b36

     # red
     color1 = #dc322f
     color9 = #cb4b16

     # green
     color2 = #8599020
     color10 = #586e75

     # yellow
     color3 = #b58900
     color11 = #657b83

     # blue
     color4 = #268bd2
     color12 = #839496

     # magenta
     color5 = #d33682
     color13 = #6c71c4

     # cyan
     color6 = #2aa198
     color14 = #93a1a1

     # white
     color7 = #eee8d5
     color15 = #fdf6e3
  '';

}
