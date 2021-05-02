{ config, pkgs, lib, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "glyph";
  home.homeDirectory = "/home/glyph";

  programs = {
    git = {
      enable = true;
      userName = "glyph";
      userEmail = "mail@strangegly.ph";
    };

    vim = {
      settings.expandtab = true;
      extraConfig = ''
        syntax on
        filetype indent plugin on
      '';
    };

    fish = {
      enable = true;
      shellAliases = {
        emacs = "emacs -nw";
        ".." = "cd ..";
        gs = "git status -sb";
        ls = "exa";
        ungz = "tar -xvf";
        unbz = "tar -xvjf";
      };
      functions = import ./fish_functions.nix;
      plugins = [{
        name = "bang-bang";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-bang-bang";
          rev = "f969c618301163273d0a03d002614d9a81952c1e";
          sha256 = "1r3d4wgdylnc857j08lbdscqbm9lxbm1wqzbkqz1jf8bgq2rvk03";
        };
      }];
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 1800;
    };
  };


  home.file = {
    ".emacs.d" = {
      recursive = true;
      source = pkgs.fetchFromGitHub {
        owner = "syl20bnr";
        repo = "spacemacs";
        rev = "2182be9440dc2f862c4248b43bb7c74a30e9c308";
        sha256 = "1gvyn0d5c49m5rqm5db4fcs4vpf30jiyijivy83xyvic056yb1dn";
      };
    };
    ".spacemacs".source = ./dotfiles/spacemacs;
  };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
