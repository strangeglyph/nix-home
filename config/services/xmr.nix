{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.glyph.xmr;
in
{
  imports = [
    ./restic-backup.nix
  ];

  options.glyph = {
    xmr.enable = mkEnableOption { description = "xmr tools"; };
  };

  config = mkIf cfg.enable {
    users.users.monero-user = {
      isNormalUser = true;
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRwfYnEBA8Pdsqui9xxLkk7KYpKjA01YvzHx8Sfe1PW lschuetze@aeolus"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFCfbpXsvpFUdCa6QL9PMloDtbTyqvvxLML7o/7w2Pi glyph@rosetta"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUkBx2KFNuQ4K6h7RSxzHNE7Iq/cpiuCD7y97NMq6l2 glyph@pathfinder"
      ];
    };
    home-manager.users.monero-user.imports = [ ../../home/moonlight/monero.nix ];

    environment.systemPackages = with pkgs; [
      monero-cli
    ];

    services.monero = {
      enable = true;
      prune = true;
    };

    glyph.restic."monero".paths = [
      "/home/monero/wallet"
    ];
  };
}