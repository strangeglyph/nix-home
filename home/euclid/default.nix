{ config, pkgs, lib, ... }:

{
  imports = [ ../default.nix ];

  programs.alacritty.settings.font.size = lib.mkForce 12;
}
