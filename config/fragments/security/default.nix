{
  pkgs,
  inputs,
  ...
}:
let
  nixpkgs-small = import inputs.nixpkgs-small { };
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
    ];

    # Security hotfixes
    nixpkgs.overlays = [
    ];
  };
}
