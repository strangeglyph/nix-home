{ config, pkgs, ... }:

{
    imports = [ ./default.nix ];

    home.username = "root";
    home.homeDirectory = "/root";

    home.stateVersion = "21.05";
}
