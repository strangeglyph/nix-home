{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./presets/server.nix
#    ./services/fompf.nix
    ./services/cookbook.nix
    ./services/cartograph.nix
    ./services/nextcloud.nix
    ./services/minecraft.nix
#    ./utils/pgsql_update.nix
  ];
  

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  networking.hostName = "philae";
  networking.interfaces.ens3.useDHCP = true;
  
  nix = {
    settings.trusted-users = [ "root" "@wheel" ];
    nrBuildUsers = 100;
  };

  age.secrets = {
    cloudflare_api.file = ./agenix/cloudflare_secrets.age;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@admin.apophenic.net";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cloudflare_api.path;
    };
    http-challenge-host = "acme.strangegly.ph";
    certs."apophenic.net" = {
      domain = "*.apophenic.net";
      group = config.services.nginx.group;
    };
    certs."acme.strangegly.ph" = {
      extraDomainNames = [ "cookbook.strangegly.ph" ];
    };
  };

  services = {
    cookbook = {
      enable = true;
      vhost = "cookbook.apophenic.net";
      site-name = "Glyph's Cookbook";
      recipe-folder = inputs.cookbook-recipes;
      acme-uses-dns = true;
      acme-host = "apophenic.net";
    };
    nginx.virtualHosts."cookbook.strangegly.ph" = {
      forceSSL = true;
      useACMEHost = config.security.acme.http-challenge-host;
      globalRedirect = "cookbook.apophenic.net";
    };
    cartograph = {
      enable = true;
      vhost = "wo-ist-ole.strangegly.ph";
      site-name = "Wo Ist Ole?";
    };
    nextcloud = {
      enable = true;
      hostName = "cloud.strangegly.ph";
      package = pkgs.nextcloud30;
    };
    postgresql.package = pkgs.postgresql_16;
    minecraft.enable = false;
  };

  users.users = {
    glyph = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRwfYnEBA8Pdsqui9xxLkk7KYpKjA01YvzHx8Sfe1PW lschuetze@aeolus"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFCfbpXsvpFUdCa6QL9PMloDtbTyqvvxLML7o/7w2Pi glyph@rosetta"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUkBx2KFNuQ4K6h7RSxzHNE7Iq/cpiuCD7y97NMq6l2 glyph@pathfinder"
      ];
    };
    fompf = {
      isNormalUser = true;
      shell = pkgs.fish;
    };
    minecraft = {
      isNormalUser = true;
      shell = pkgs.fish;
    };
  };
  home-manager.users.root.imports = [ ../home/philae/root.nix ];
  home-manager.users.glyph.imports = [ ../home/philae/glyph.nix ];


  system.stateVersion = "21.05";
}
