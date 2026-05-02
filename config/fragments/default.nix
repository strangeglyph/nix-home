{ ... }:
{
  imports = [
    ./users
    ./desktop
    ./shell
    ./security
    ./dev
    ./tools
    ./system
    ./theme
    ./keyboard.nix
    ./nix.nix
    ../../secrets/confidential.nix
  ];

  config = {
    system.stateVersion = "21.05";
  };
}
