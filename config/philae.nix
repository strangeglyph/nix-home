{ config, pkgs, lib, ... }:

{
  imports = [
    ./presets/server.nix
    ./services/fompf.nix
    ./services/cookbook.nix
    ./services/nextcloud.nix
    ./services/minecraft.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  networking.hostName = "philae";
  networking.interfaces.ens3.useDHCP = true;
  
  nix = {
    trustedUsers = [ "root" "@wheel" ];
    nrBuildUsers = 100;
  };

  security.acme.challenge-host = "acme.strangegly.ph";

  services = {
    cookbook = {
      enable = true;
      vhost = "cookbook.strangegly.ph";
    };
    nextcloud = {
      enable = true;
      hostName = "cloud.strangegly.ph";
      package = pkgs.nextcloud24;
    };
    minecraft.enable = true;
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


  system.stateVersion = "21.05";
}
