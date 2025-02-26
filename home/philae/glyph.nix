{ config, pkgs, ... }:

{
    imports = [ ./default.nix ];

    home.username = "glyph";
    home.homeDirectory = "/home/glyph";

    home.stateVersion = "21.05";
}
