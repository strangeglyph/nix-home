{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-compat = {
      url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    firefox = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cookbook = {
      url = "github:strangeglyph/cookbook";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cookbook-recipes = {
      url = "github:strangeglyph/cookbook-recipes";
      flake = false;
    };
    cartograph = {
      url = "github:strangeglyph/cartograph";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      colmena,
      disko,
      home-manager,
      agenix,
      agenix-rekey,
      sops-nix,
      ...
    }:
    {
      nixosConfigurations = self.outputs.colmenaHive.nodes;
      colmenaHive = colmena.lib.makeHive self.outputs.rawHive;
      rawHive = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ ];
          };
          specialArgs = {
            inherit inputs;
          };
        };

        defaults =
          {
            name,
            nodes,
            pkgs,
            ...
          }:
          let
            system = pkgs.stdenv.hostPlatform.system;
          in
          {
            imports = [
              disko.nixosModules.disko
              home-manager.nixosModules.home-manager
              agenix.nixosModules.default
              agenix-rekey.nixosModules.default
              sops-nix.nixosModules.sops
              ./config/utils
              ./config/fragments
              ./packages
              ./highlevel_modules
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

              sops.defaultSopsFile = secrets/sops/secrets.yaml;

              environment.systemPackages = [
                agenix-rekey.packages.${system}.default
                colmena.packages.${system}.colmena
              ];

              nix.package = pkgs.lixPackageSets.latest.lix;
            };
          };

        aeolus =
          {
            name,
            node,
            pkgs,
            ...
          }:
          {
            deployment = {
              allowLocalDeployment = true;
              targetHost = null;
              tags = [ "interstice-client" ];
            };
          };

        philae =
          {
            name,
            node,
            pkgs,
            ...
          }:
          {
            deployment = {
              targetHost = "philae.interstice.apophenic.net";
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

        moonlight =
          {
            name,
            node,
            pkgs,
            ...
          }:
          {
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
