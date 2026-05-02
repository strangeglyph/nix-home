{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.glyph.theme.fonts;
  mkFontOpt = desc: {
    name = mkOption {
      description = "Name of the default ${desc} font";
      type = types.str;
    };
    package = mkOption {
      description = "Package of the default ${desc} font";
      type = types.package;
    };
  };
in
{
  options.glyph.theme.fonts = {
    emoji = mkFontOpt "emoji";
    monospace = mkFontOpt "monospace";
    serif = mkFontOpt "serif";
    sans = mkFontOpt "sans";
    sizes = mkOption {
      description = "Default font sizes by category";
      type = types.attrsOf types.float;
    };
  };

  config = {
    console.font = "Lat2-Terminus16";

    glyph.theme.fonts = with pkgs; {
      emoji = {
        name = "Noto Color Emoji";
        package = noto-fonts-color-emoji;
      };
      monospace = {
        name = "SauceCodePro Nerd Font";
        package = nerd-fonts.sauce-code-pro;
      };
      serif = {
        name = "NotoSerif Nerd Font";
        package = nerd-fonts.noto;
      };
      sans = {
        name = "NotoSans Nerd Font";
        package = nerd-fonts.noto;
      };
      sizes = {
        applications = 12.0;
        desktop = 12.0;
        popups = 12.0;
        terminal = 12.0;
      };
    };

    fonts = lib.mkIf config.glyph.dm.enable {
      packages = with pkgs; [
        cfg.emoji.package
        cfg.monospace.package
        cfg.serif.package
        cfg.sans.package
        #
        nerd-fonts.dejavu-sans-mono
        noto-fonts-cjk-sans
        cantarell-fonts
        liberation_ttf
        lmodern # tex
        jost # futura-like
      ];
      fontconfig.defaultFonts = {
        sansSerif = [
          cfg.sans.name
          "Noto Color Emoji"
          "Noto Emoji"
        ];
        serif = [
          cfg.serif.name
          "Noto Color Emoji"
          "Noto Emoji"
        ];
        monospace = [
          cfg.monospace.name
          "Noto Color Emoji"
          "Noto Emoji"
        ];
        emoji = [
          cfg.emoji.name
          "Noto Emoji"
        ];
      };
    };
  };
}
