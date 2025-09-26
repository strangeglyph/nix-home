{ config, pkgs, lib, ... }:

{
  imports = [ ../default.nix ];

  wayland.windowManager.sway.enable = false;
}
