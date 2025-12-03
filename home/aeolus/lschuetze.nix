{ config, pkgs, lib, ... }:

{
    imports = [ ./default.nix ];

    home.username = "lschuetze";
    home.homeDirectory = "/home/lschuetze";

    programs.git.settings.user.name = lib.mkForce "lschuetze";
    programs.git.settings.user.email = lib.mkForce "lschuetze@mpi-sws.org";
    programs.git.settings.safe.directory = "/etc/nixos/nixos.d/.git";

    home.stateVersion = "21.05"; 
}
