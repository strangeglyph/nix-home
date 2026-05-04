{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) types mkOption;
in
{
  options.glyph.users = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          shell = mkOption {
            type = types.enum [ "fish" ];
            default = "fish";
          };
        };
      }
    );
  };

  config = {
    programs.fish.enable = true;

    users.users = config.glib.eachHumanUserAndRoot (
      name: cfg:
      lib.mkIf (name == "root" || cfg.shell == "fish") {
        shell = pkgs.fish;
      }
    );

    home-manager.users = config.glib.eachHumanUserAndRoot (
      name: cfg: {
        programs.fish = {
          enable = name == "root" || cfg.shell == "fish";
          shellAliases = {
            emacs = "emacs -nw";
            ".." = "cd ..";
            gs = "git status -sb";
            ls = "exa";
            cat = "bat";
            ungz = "tar -xvf";
            unbz = "tar -xvjf";
          };
          plugins = [
            {
              name = "bang-bang";
              src = pkgs.fetchFromGitHub {
                owner = "oh-my-fish";
                repo = "plugin-bang-bang";
                rev = "ec991b80ba7d4dda7a962167b036efc5c2d79419";
                sha256 = "1r3d4wgdylnc857j08lbdscqbm9lxbm1wqzbkqz1jf8bgq2rvk03";
              };
            }
          ];
          interactiveShellInit = ''
            ${lib.getExe pkgs.direnv} hook fish | source
          '';
        };

        # Fuzzy cli search
        programs.fzf = {
          enable = true;
          enableFishIntegration = true;
        };
      }
    );
  };
}
