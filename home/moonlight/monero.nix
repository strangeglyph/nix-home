{ config, pkgs, ... }:

{
    imports = [ ./default.nix ];

    home.username = "monero-user";
    home.homeDirectory = "/home/monero-user";

    home.stateVersion = "25.11";
}
