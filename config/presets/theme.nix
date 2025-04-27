{ pkgs, config, ... }:

let pastel-dark-theme = rec {
  scheme = "pastel-dark";
  author = "glyph";
  description = "dark background, bright colors. green accents";

  main-base = "161320";
  alt-base = "383956";
  accent = pastel-green;
  alt-accent = "e8a1ae";
  main-text = pastel-blue;
  error = dark-red;
  urgent = error;
  warning = dark-orange;
  highlight = warning;
  
  pastel-yellow = "fae380";
  pastel-yellow-green = "d8eca7";
  pastel-green = "baebad";
  pastel-green-blue = "b2ebc2";
  pastel-blue = "b8eadf";
  pastel-blue-purple = "bdddea";
  pastel-purple-blue = "c2cbea";
  pastel-purple = "d1c7ea";
  pastel-purple-pink = "e4cceb";
  pastel-pink = "ebd1e4";
  pastel-red = "f2c0ca";

  sat-red = "f693a7";
  sat-orange = "fc915f";
  sat-yellow = "ffdf52";
  sat-green = "94f07f";
  sat-cyan = "8decd8";
  sat-blue = "99abeb";
  sat-magenta = "d9a4ea";

  dark-red = "eb4f4c";
  dark-orange = "eb692d";
  dark-yellow = "efc91f";
  dark-green = "6bdb51";
  dark-cyan = "60d7bd";
  dark-blue = "6e84d4";
  dark-magenta = "db7bd1";

  pastel-saturated-green = "94fa9c";
  pastel-saturated-cyan = "95f9dd";
  pastel-saturated-blue = "98cef8";

  # std: dark
  # stylix: default bg, dark text
  base00 = main-base; 
  # stylix: alt (overlay) bg, incomplete progress bar, alt dark text
  base01 = alt-base; 
  # stylix: selection, complete progress bar, dark text widget alt off bg
  base02 = accent;
  # stylix: unfocused window border, list selection
  # need to see in action, set it to glare mode for now
  base03 = "ff0000"; 
  # stylix: alt text, logo "alt color"
  base04 = alt-accent;
  # stylix: default text, window title, logo "main color"
  base05 = main-text;
  # stylix: notification low urgency bg
  base06 = main-base; 
  # std: light
  base07 = main-text; 
  # std: red
  # stylix: error, urgent window border, notification high urgency text
  base08 = error; 
  # std: orange
  # stylix: urgent, dark text widget alt on bg
  base09 = warning; 
  # std: yellow
  # stylix: warning, notification low urgency text
  # we: which one is it? notification or warning
  base0A = sat-yellow; 
  # std: green
  # we: pastel-theme saturated variant a, just to fill something in
  base0B = sat-green; 
  # std: cyan
  # we: pastel-theme saturated variant b, just to fill something in
  base0C = sat-cyan; 
  # std: blue
  # stylix: focused window border, notification window border, dark text widget off bg
  #         list unselected
  base0D = sat-blue; 
  # std: magenta
  # stylix: dark text widget on bg
  base0E = sat-magenta; 
  # std: brown
  # stylix: notification high urgency bg
  base0F = main-base;
  # std: extra dark
  base10 = pastel-green-blue; 
  # std: extra extra dark
  base11 = pastel-blue;
  # std: bright red
  # we: hover text, desaturated very-light off-red
  base12 = pastel-red; 
  # std: bright orange
  base13 = pastel-yellow;
  # std: bright green
  base14 = pastel-green;
  # std: bright cyan
  base15 = pastel-green-blue;
  # std: bright blue
  base16 = pastel-blue; 
  # std: bright magenta
  base17 = pastel-purple;
};
in
{
  stylix = {
    enable = true;
    autoEnable = false;
  
    base16Scheme = pastel-dark-theme;
    polarity = "dark";

    image = config.lib.stylix.pixel "base01";
    imageScalingMode = "fill";

    fonts = with pkgs; {
      emoji = { 
        name = "Noto Color Emoji"; 
        package = noto-fonts;
      };
      monospace = {
        #name = "DejaVu Sans Mono";
        #package = dejavu_fonts;
        name = "SauceCodePro Nerd Font";
        package = nerdfonts.override { fonts = [ "SourceCodePro" ]; };
      };
      serif = {
        #name = "DejaVu Serif";
        #package = dejavu_fonts;
        name = "NotoSerif Nerd Font";
        package = nerdfonts.override { fonts = [ "Noto" ]; };
      };
      sansSerif = {
        #name = "DejaVu Sans";
        #package = dejavu_fonts;
        name = "NotoSans Nerd Font";
        package = nerdfonts.override { fonts = [ "Noto" ]; };
      };
      sizes = {
        applications = 12.0;
        desktop = 12.0;
        popups = 12.0;
        terminal = 12.0;
      };
    };

    opacity = {
      applications = 1.0;
      desktop = 0.0;
      popups = 0.8;
      terminal = 0.8;
    };

    targets = {
      gnome.enable = true;
      grub = {
        enable = true;
        #useWallpaper = true;
      };
    };
  };

  # standard color map: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
  console.colors = with pastel-dark-theme; [
    main-base
    sat-red
    sat-green
    sat-yellow
    sat-blue
    sat-magenta
    sat-cyan
    main-text
    alt-base
    pastel-red
    pastel-green
    pastel-yellow
    pastel-blue
    pastel-pink
    pastel-green-blue
    accent
  ];

  home-manager.sharedModules = [{
    stylix.autoEnable = false;
    stylix.targets = {
      waybar.enable = false; # managed manually
      sway.enable = false; # managed manually
      swaylock.enable = false; # managed manually
      alacritty.enable = false; # managed manually
      gnome.enable = true;
    };
  }];
}
