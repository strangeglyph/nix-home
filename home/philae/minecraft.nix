{ config, pkgs, ... }:

{
    imports = [ ./default.nix ];

    home.username = "minecraft";
    home.homeDirectory = "/home/minecraft";

    home.stateVersion = "21.05";
}
