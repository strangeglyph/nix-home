{ config, pkgs, lib, ... }:

{
    imports = [ ./default.nix ];

    home.username = "lschuetze";
    home.homeDirectory = "/home/lschuetze";

    programs.git.userName = lib.mkForce "lschuetze";
    programs.git.userEmail = lib.mkForce "lschuetze@mpi-sws.org";
    programs.git.extraConfig = {
      safe.directory = "/etc/nixos/nixos.d/.git";
    };

    home.stateVersion = "21.05"; 
}
