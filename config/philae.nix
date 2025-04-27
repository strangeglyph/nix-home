{ config, pkgs, lib, ... }:

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

  security.acme.challenge-host = "acme.strangegly.ph";

  services = {
    cookbook = {
      enable = true;
      vhost = "cookbook.strangegly.ph";
      site-name = "Glyph's Cookbook";
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
  home-manager.users.glyph.imports = [ ./home/philae/glyph.nix ];


  system.stateVersion = "21.05";
}
