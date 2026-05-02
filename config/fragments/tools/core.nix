{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    mkMerge
    mkIf
    types
    ;
  cfg = config.glyph.tools.core;
  glib = config.glib;
in
{
  options.glyph.tools.core = {
    enable = mkOption {
      description = "Enable core tools";
      default = true;
      type = types.bool;
    };
    diagnostics.enable = mkOption {
      description = "Enable diagnostics tools";
      default = cfg.enable;
      type = types.bool;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs = {
        vim.enable = true;
        vim.defaultEditor = true;
        nano.nanorc = ''
          set tabsize 4
          set tabstospaces
        '';
      };

      home-manager.users = glib.eachHumanUserAndRoot' (name: {
        programs.vim.settings = {
          expandtab = true;
        };
        programs.vim.extraConfig = ''
          syntax on
          filetype indent plugin on
        '';
      });

      environment.systemPackages = with pkgs; [
        binutils
        gnumake

        htop
        lsof
        pv
        file

        zip
        unzip

        curl
        jq

        git
        jujutsu

        ripgrep # modern grep
        eza # modern ls
        bat # modern cat
      ];
    })
    (mkIf cfg.diagnostics.enable {
      programs = {
        mtr.enable = true; # traceroute
        dconf.enable = true; # gnome config query / update
      };

      environment.systemPackages = with pkgs; [
        # hardware reports
        pciutils
        lshw

        # networking tools
        wirelesstools
        ethtool
        socat

        # dns
        dig
      ];
    })
  ];
}
