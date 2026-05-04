{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (config) glib;
  cfg = config.glyph.theme.color;
  colorType = types.mkOptionType {
    name = "color";
    description = "HTML color code";
    descriptionClass = "noun";
    check = x: types.str.check x && builtins.match "#[[:xdigit:]]{6}" x != null;
    inherit (types.str) merge;
  };
  mkColorOpt =
    description:
    mkOption {
      inherit description;
      type = colorType;
    };
  mkColorRef =
    color:
    mkOption {
      type = colorType;
      readOnly = true;
      default = color;
    };
in
{
  options.glyph.theme.color = {
    default-scheme = mkOption {
      description = "Color scheme to use unless overridden (as a name of glyph.color.schemes)";
      type = types.str;
    };
    tty = mkOption {
      description = "TTY scheme";
      type = types.str;
      default = cfg.default-scheme;
    };

    schemes = mkOption {
      description = "Color scheme definitions, in the [base16.nix](https://github.com/SenchoPens/base16.nix) format";
      default = { };
      type = types.attrsOf (
        types.submodule (
          { name, config, ... }:
          {
            options = {
              system = mkOption {
                description = "Scheme type (base24 or base16)";
                default = "base24";
                type = types.enum [
                  "base24"
                  "base16"
                ];
              };
              name = mkOption {
                description = "Scheme name";
                type = types.str;
                default = name;
              };
              slug = mkOption {
                description = "Scheme slug";
                type = types.str;
                default = glib.str.slugify config.name;
              };
              author = mkOption {
                description = "Scheme author";
                type = types.str;
                default = "glyph";
              };
              description = mkOption {
                description = "A brief description of the scheme";
                type = types.nullOr types.str;
                default = null;
              };
              variant = mkOption {
                description = "Scheme variant (e.g. light or dark)";
                type = types.nullOr types.str;
                default = null;
              };
              palette = {
                base00 = mkColorOpt "main background color";
                base01 = mkColorOpt "status background color";
                base02 = mkColorOpt "selection color";
                base03 = mkColorOpt "inactive color";
                base04 = mkColorOpt "status foreground color";
                base05 = mkColorOpt "main foreground color";
                base06 = mkColorOpt "secondary foreground color";
                base07 = mkColorOpt "tertiary foreground color";
                base08 = mkColorOpt "error and urgent color (typically red)";
                base09 = mkColorOpt "warning color (typically orange)";
                base0A = mkColorOpt "alert color (typically yellow)";
                base0B = mkColorOpt "okay color (typically green)";
                base0C = mkColorOpt "accent color (typically cyan)";
                base0D = mkColorOpt "focus color (typically blue)";
                base0E = mkColorOpt "(typically magenta)";
                base0F = mkColorOpt "critical color (typically deep red)";
                base10 = mkColorOpt "secondary background color";
                base11 = mkColorOpt "tertiary background color";
                base12 = mkColorOpt "(typically bright red)";
                base13 = mkColorOpt "(typically bright orange)";
                base14 = mkColorOpt "(typically bright green)";
                base15 = mkColorOpt "(typically bright cyan)";
                base16 = mkColorOpt "(typically bright blue)";
                base17 = mkColorOpt "(typically bright magenta)";
              };
              mnemonics = {
                background =
                  with config.palette;
                  builtins.mapAttrs (_: mkColorRef) {
                    main = base00;
                    status = base01;
                    selection = base02;
                    secondary = base10;
                    tertiary = base11;
                  };
                foreground =
                  with config.palette;
                  builtins.mapAttrs (_: mkColorRef) {
                    main = base05;
                    status = base04;
                    secondary = base06;
                    tertiary = base07;
                  };
                category =
                  with config.palette;
                  builtins.mapAttrs (_: mkColorRef) {
                    inactive = base06;
                    critical = base0F;
                    error = base08;
                    warn = base09;
                    alert = base0A;
                    okay = base0B;
                    focus = base0D;
                    accent = base0C;
                  };
                color =
                  with config.palette;
                  builtins.mapAttrs (_: builtins.mapAttrs (_: mkColorRef)) {
                    red.main = base08;
                    red.deep = base0F;
                    red.bright = base12;

                    orange.main = base09;
                    orange.bright = base13;

                    yellow.main = base0A;

                    green.main = base0B;
                    green.bright = base14;

                    cyan.main = base0C;
                    cyan.bright = base15;

                    blue.main = base0D;
                    blue.bright = base16;

                    magenta.main = base0E;
                    magenta.bright = base17;
                  };
              };
            };
          }
        )
      );
    };
  };

  config = {
    glyph.theme.color = {
      default-scheme = "pastel-dark";
      schemes."pastel-dark" = {
        variant = "dark";
        description = "lightly desaturate, bright colors, mint accents";
        palette = {
          base00 = "#161320";
          base01 = "#383956";
          base02 = "#baebad";
          base03 = "#ff0000";
          base04 = "#e8a1ae";
          base05 = "#b8eadf";
          base06 = "#161320";
          base07 = "#b8eadf";
          base08 = "#eb4f4c";
          base09 = "#eb692d";
          base0A = "#ffdf52";
          base0B = "#94f07f";
          base0C = "#8decd8";
          base0D = "#99abeb";
          base0E = "#d9a4ea";
          base0F = "#b02c2a";
          base10 = "#383956";
          base11 = "#161320";
          base12 = "#f2c0ca";
          base13 = "#fea380";
          base14 = "#baebad";
          base15 = "#b2ebc2";
          base16 = "#b8eadf";
          base17 = "#d1c7ea";
        };
      };
    };

    # standard 16-color map: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
    console.colors =
      with cfg.schemes."${cfg.tty}".mnemonics;
      lib.map glib.color.strip [
        background.main
        category.error
        category.okay # Successful systemd services
        category.alert
        category.focus
        color.magenta.main # unused?
        category.accent
        foreground.main

        background.status
        category.error # Failed systemd services
        category.alert # stage header
        color.magenta.main # unused
        color.magenta.main # unused
        color.magenta.main # unused
        color.magenta.main # unused
        category.focus # motd + systemd service name
      ];
  };
}
