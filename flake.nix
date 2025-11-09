{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-25.05"; };
    #lix = {
    #  url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    flake-compat = {
      url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
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

  outputs = inputs@{ self, nixpkgs, colmena, disko, home-manager, stylix, agenix, agenix-rekey, ... }:
  {
    nixosConfigurations = self.outputs.colmenaHive.nodes;
    colmenaHive = colmena.lib.makeHive self.outputs.rawHive;
    rawHive = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
        specialArgs = {
          inherit inputs;
        };
      };

      defaults = { name, nodes, pkgs, ... }: 
      let
        system = pkgs.system;
      in {
        imports = [
          #lix.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          ./config/utils/globals.nix
          ./config/default.nix
          ./hw/${name}.nix
          ./config/${name}.nix
        ];

        config = {
          networking.hostName = name;

          age.rekey = {
            masterIdentities = [ ./secrets/age_id.age ];
            hostPubkey = ./secrets/${name}.pub;
            storageMode = "local";
            localStorageDir = ./. + "/secrets/rekeyed/${name}";
          };

          environment.systemPackages = [
            agenix-rekey.packages.${system}.default
            colmena.packages.${system}.colmena
          ];

          nix.package = pkgs.lixPackageSets.latest.lix;
        };
      };

      aeolus = { name, node, pkgs, ... }: {
        deployment = {
          allowLocalDeployment = true;
          targetHost = null;
          tags = [ "interstice-client" ];
        };
      };
      
      philae = { name, node, pkgs, ... }: {
        deployment = {
          targetHost = "philae.apophenic.net";
          tags = [ 
            "interstice-server"
            "interstice-client"
            "sso-server"
            "sso-client"
            "web"
            "public"
          ];
        };
      };

      moonlight = { name, node, pkgs, ... }: {
        imports = [
          ./hw/disko/moonlight.nix  
        ];

        deployment = {
          targetHost = "moonlight.interstice.apophenic.net";
          tags = [ "interstice-client" ];
        };
      };
    };

    agenix-rekey = agenix-rekey.configure {
      userFlake = self;
      nixosConfigurations = self.outputs.colmenaHive.nodes;
    };
  };
}
