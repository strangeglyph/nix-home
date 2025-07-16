{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-25.05"; };
    lix = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cookbook = {
      url = "github:strangeglyph/cookbook";
    };
    cookbook-recipes = {
      url = "github:strangeglyph/cookbook-recipes";
      flake = false;
    };
    cartograph = {
      url = "github:strangeglyph/cartograph";
    };
    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
  let default-config = local-conf: hw-conf: inputs@{ lix, home-manager, stylix, agenix, ... }:
    inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        lix.nixosModules.default
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        agenix.nixosModules.default
        { environment.systemPackages = [ agenix.packages.${system}.default ]; }
        #
        ./config/utils/globals.nix
        hw-conf
        ./config/default.nix
        local-conf
      ];
      specialArgs = { 
        inherit inputs system;
      };
    };
  in
  {
    nixosConfigurations = {
      aeolus = default-config ./config/aeolus.nix ./hw/aeolus.nix inputs;
      philae = default-config ./config/philae.nix ./hw/philae.nix inputs;
    };
  };
}
