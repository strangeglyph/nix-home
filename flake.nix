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
    colmena = {
      url = "github:zhaofengli/colmena";
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
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
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

  outputs = inputs@{ self, lix, colmena, home-manager, stylix, agenix, agenix-rekey, ... }:
  let default-config = hostname:
    inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        lix.nixosModules.default
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        agenix.nixosModules.default
        agenix-rekey.nixosModules.default
        #
        {
          age.rekey = {
            masterIdentities = [ ./secrets/age_id.age ];
            hostPubkey = ./secrets/${hostname}.pub;
            storageMode = "local";
            localStorageDir = ./. + "/secrets/rekeyed/${hostname}";
          };

          environment.systemPackages = [ 
            agenix-rekey.packages.${system}.default
          ]; 
        }
        ./config/utils/globals.nix
        ./hw/${hostname}.nix
        ./config/default.nix
        ./config/${hostname}.nix
      ];
      specialArgs = { 
        inherit inputs system;
      };
    };
  in
  {
    nixosConfigurations = {
      aeolus = default-config "aeolus";
      philae = default-config "philae";
    };
    colmenaHive = colmena.lib.mkHive {

    };
    agenix-rekey = agenix-rekey.configure {
      userFlake = self;
      nixosConfigurations = self.nixosConfigurations;
    };
  };
}
