{ config, pkgs, lib, ... }:

{

  imports = [
    ./dotfiles/sway/sway.nix
    ./dotfiles/hyprland/hyprland.nix
    ./dotfiles/starship.nix
  ];

  # Put this into the machine-specific section
  wayland.windowManager.sway.enable = lib.mkDefault false;
  wayland.windowManager.hyprland.enable = lib.mkDefault false;

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
      # functions = import ./fish_functions.nix;
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

    # Mode+D launcher for sway
    # (Switched for bemenu)
    # wofi = import ./dotfiles/wofi.nix { inherit pkgs lib; };
  };

  services = {
    # Automount usb sticks
    udiskie = {
      enable = true;
      automount = true;
    };
  };



  home.file = {
    #".emacs.d" = {
    #  recursive = true;
    #  source = fetchGit {
    #    url = "git@github.com:syl20bnr/spacemacs.git";
    #    ref = "develop";
    #  };
    #};
    #".spacemacs".source = ./dotfiles/spacemacs;
    #".agda/defaults".text = ''
    #   standard-library
    #'';
  };

  xdg.configFile = {
    ".environment.d/ssh-agent.conf".text = ''
      SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
    '';
  };

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
