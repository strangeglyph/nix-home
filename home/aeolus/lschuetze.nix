{ config, pkgs, lib, ... }:

{
    home.username = "lschuetze";
    home.homeDirectory = "/home/lschuetze";

    programs.git.userName = lib.mkForce "lschuetze";
    programs.git.userEmail = lib.mkForce "lschuetze@mpi-sws.org";

    home.stateVersion = "21.05"; 
}
