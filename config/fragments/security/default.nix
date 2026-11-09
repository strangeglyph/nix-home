{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  nixpkgs-small = import inputs.nixpkgs-small { };
  bubblewrap-utility-script = pkgs.writeShellScriptBin "bbwrap" ''
    ${lib.getExe pkgs.bubblewrap} \
      --ro-bind /nix /nix \
      --ro-bind /usr /usr \
      --ro-bind /lib /lib \
      --ro-bind /lib64 /lib64 \
      --ro-bind /bin /bin \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --ro-bind /etc/hosts /etc/hosts \
      --ro-bind /etc/ssl /etc/ssl \
      --ro-bind /etc/passwd /etc/passwd \
      --ro-bind /etc/group /etc/group \
      --ro-bind "$PWD" "$PWD" \
      --bind "$HOME/.codex" "$HOME/.codex" \
      --ro-bind "$HOME/.nvm" "$HOME/.nvm" \
      --tmpfs /tmp \
      --proc /proc \
      --dev /dev \
      --unshare-all \
      --share-net \
      --die-with-parent \
      $@
  '';
in
{
  imports = [
    ./ssh.nix
    ./kernel.nix
    ./pam.nix
    ./network.nix
  ];

  config = {
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];

    security.sudo.extraConfig = "Defaults timestamp_timeout=30";
    security.polkit.enable = true;
    security.apparmor.enable = true;

    environment.systemPackages = [
      pkgs.bubblewrap
      bubblewrap-utility-script
    ];

    # Security hotfixes
    nixpkgs.overlays = [
      # https://github.com/NixOS/nixpkgs/pull/576865
      (final: prev: {
        inherit (nixpkgs-small)
          php
          php82
          php83
          php84
          php85
          nextcloud
          ;
      })
    ];
  };
}
