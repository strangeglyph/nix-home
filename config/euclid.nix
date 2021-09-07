{ config, pkgs, ... }:

{
  imports = [
    ./presets/headful.nix
  ];

  networking = {
    hostName = "euclid";
    interfaces.enp0s3.useDHCP = true;
  };

  virtualisation.virtualbox.guest.enable = true;

  users.users.glyph = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  services.xserver.displayManager.autologin = {
    enable = true;
    user = "glyph";
  };
  services.mingetty.autologinUser = "glyph";

  system.stateVersion = "20.09";
}
