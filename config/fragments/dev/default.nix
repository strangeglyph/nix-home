{
  pkgs,
  ...
}:
{
  imports = [
    ./rust.nix
    ./python.nix
    ./vcs.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      direnv
      devenv
      vscode-fhs
    ];
  };
}
