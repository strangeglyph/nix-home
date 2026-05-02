{ ... }:
let
in
{
  imports = [
    ./fragments
    ./services
  ];

  glyph = {
    users.glyph.privileged = true;

    restic-server.enable = true;
  };
}
