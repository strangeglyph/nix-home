{ config, pkgs, lib, ... }:

let
  mozilla-overlays = fetchTarball { url = https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz; };
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs = {
    git = {
      enable = true;
      userName = "glyph";
      userEmail = "mail@strangegly.ph";
      extraConfig.init.defaultBranch = "main";
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
      interactiveShellInit = ''
        direnv hook fish | source
      '';
    };

    # Fuzzy cli search
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    alacritty = import ./dotfiles/alacritty.nix { inherit pkgs; };
    starship = import ./dotfiles/starship.nix { inherit pkgs lib; };
    waybar = import ./dotfiles/waybar.nix { inherit pkgs lib; };
    swaylock = import ./dotfiles/swaylock.nix { inherit pkgs lib; };
    wofi = import ./dotfiles/wofi.nix { inherit pkgs lib; };
  };

  xsession.windowManager.i3 = {
    enable = true;
    config = import ./dotfiles/i3.nix { inherit pkgs lib; };
  };

  wayland.windowManager.sway = import ./dotfiles/sway.nix { inherit pkgs lib; };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 1800;
    };
    udiskie = {
      enable = true;
      automount = true;
    };
    # popup notification daemon
    # dunst = import ./dotfiles/dunst.nix { inherit pkgs; };
    swayidle = import ./dotfiles/swayidle.nix { inherit pkgs; };
  };


  home.file = {
    ".emacs.d" = {
      recursive = true;
      source = pkgs.fetchFromGitHub {
        owner = "syl20bnr";
        repo = "spacemacs";
        rev = "develop";
        sha256 = "16qnz7nvp712gph1wwgznpk1bia4rggq3flr89ps0b26b95yhcww";
      };
    };
    ".spacemacs".source = ./dotfiles/spacemacs;
    ".agda/defaults".text = ''
       standard-library
    '';
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (import "${mozilla-overlays}") ];
  xdg.configFile."nixpkgs/overlays/mozilla-overlays".source = mozilla-overlays;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  #
  # (should be specified in the user config)
  # home.stateVersion = "21.03";
}
