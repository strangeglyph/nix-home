{ pkgs, lib, config, nodes, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption mkMerge;
  gservices = config.globals.services;
  cfg = config.glyph.media;
in
{
  imports = [
    ../acme.nix
    ../nginx-common.nix
    ./jellyfin.nix
  ];

  options.glyph = {
    media.enable = mkEnableOption { description = "media environment"; };
  };

  config = mkIf cfg.enable {
    nixarr = {
      enable = true;
      mediaDir = "/data/media/media";
      stateDir = "/var/lib/nixarr";
    };

    #age.secrets = {
    #  "mullvad.wg.conf" = {
    #    rekeyFile = ../../secrets/sources/vpn/mullvadd.wg.conf.age;
    #  };
    #};
  };
}