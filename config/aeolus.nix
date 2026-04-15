{
  lib,
  ...
}:

{
  imports = [
    ./services/restic-backup.nix
    ./fragments
  ];

  networking.hostName = "aeolus";

  glyph = {
    users.lschuetze.privileged = true;
    tailscale.operator = "lschuetze";

    keyboard = "qwerty";

    printer.remotes = [
      "cups.mpi-klsb.mpg.de:631"
    ];

    restic."aeolus".paths = [
      "/home/lschuetze/Documents"
      "/home/lschuetze/Projects"
    ];

    security.dnssec.enable = false; # Causes issues on mpi net

    dm.enable = true;

    dev = {
      rust = true;
      python = true;
    };

    tools = {
      editors = true;
      graphics = true;
      "3d-printing" = true;
      science = true;
    };
  };

  #home-manager.users.root.imports = [ ../home/aeolus/root.nix ];
  #home-manager.users.lschuetze.imports = [ ../home/aeolus/lschuetze.nix ];
}
