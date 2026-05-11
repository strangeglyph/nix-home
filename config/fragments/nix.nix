{
  inputs,
  nodes,
  pkgs,
  ...
}:
{
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.extraSpecialArgs = { inherit inputs nodes; };

    nix = {
      settings = {
        extra-experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operator"
        ];
        nix-path = [ "nixpkgs=flake:nixpkgs" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 90d";
      };
      optimise = {
        automatic = true;
      };
      # To make things like 'nix run nixpkgs#foo' work
      # should be obsoleted by nixpkgs.flake.source below
      #registry.nixpkgs.flake = inputs.nixpkgs;
      channel.enable = false;
    };

    nixpkgs = {
      config.allowUnfree = true;
      flake.source = inputs.nixpkgs.outPath;
    };

    programs.nix-index.enable = true;

    environment.systemPackages = with pkgs; [
      rage
      sops
      npins
      comma
    ];
  };
}
