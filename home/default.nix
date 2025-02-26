{ config, pkgs, lib, ... }:

{
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

    # Shell
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

    # Locate packages in store
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    # Terminal
    alacritty = import ./dotfiles/alacritty.nix { inherit pkgs; };

    # Shell prompt
    starship = import ./dotfiles/starship.nix { inherit pkgs lib; };

    # Status bar (check here also for color scheme)
    waybar = import ./dotfiles/waybar.nix { inherit pkgs lib; };

    # Lockscreen
    swaylock = import ./dotfiles/swaylock.nix { inherit pkgs lib; };

    # Mode+D launcher for sway
    # (Switched for bemenu)
    # wofi = import ./dotfiles/wofi.nix { inherit pkgs lib; };
  };

  # xsession.windowManager.i3 = {
  #  enable = true;
  #  config = import ./dotfiles/i3.nix { inherit pkgs lib; };
  # };

  wayland.windowManager.sway = import ./dotfiles/sway.nix { inherit pkgs lib; };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 1800;
    };
    # Automount usb sticks
    udiskie = {
      enable = true;
      automount = true;
    };
    # popup notification daemon
    # Switched for deadd-notification-center (not styled yet)
    # dunst = import ./dotfiles/dunst.nix { inherit pkgs; };

    # Lock screen when idling
    swayidle = import ./dotfiles/swayidle.nix { inherit pkgs; };

    # Automatic monitor configuration
    kanshi = import ./dotfiles/kanshi.nix { inherit pkgs lib; };
  };


  home.file = {
    ".emacs.d" = {
      recursive = true;
      source = fetchGit {
        url = "git@github.com:syl20bnr/spacemacs.git";
        ref = "develop";
      };
    };
    ".spacemacs".source = ./dotfiles/spacemacs;
    ".agda/defaults".text = ''
       standard-library
    '';
  };

  nixpkgs.config.allowUnfree = true;

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
