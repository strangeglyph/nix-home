all@{ config, pkgs, lib, inputs, ... }:
let
  globals = config.globals;
in
{
  imports = [
    ./presets/server.nix
    ./services/restic-server.nix
    ./services/xmr.nix
    ./services/media/default.nix
  ];
 
  networking.interfaces.enp2s0.useDHCP = true;
  
  nix = {
    settings.trusted-users = [ "root" "@wheel" ];
    nrBuildUsers = 100;
  };

  glyph = {
    restic-server.enable = true;
    xmr.enable = true;
    media.enable = true;
  };

  services = {
    tailscale.enable = true;
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
  };

  home-manager.users.root.imports = [ ../home/moonlight/root.nix ];
  home-manager.users.glyph.imports = [ ../home/moonlight/glyph.nix ];
  

  system.stateVersion = "25.05";
}
