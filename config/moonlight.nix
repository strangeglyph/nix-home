{ ... }:
let
in
{
  imports = [
    ./fragments
    ./services
  ];

  glyph = {
    users.glyph = {
      privileged = true;
      with-pw = true;
    };

    restic-server.enable = true;
  };
}
