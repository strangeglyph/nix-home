{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  packages = [
    pkgs.nixfmt
    pkgs.nixfmt-tree
  ];

  languages.nix.enable = true;
  languages.nix.lsp.enable = true;
}
