{
  ...
}:

{
  glyph = {
    users.lschuetze = {
      privileged = true;
      with-pw = true;
    };
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

    dm = {
      enable = true;

      noctalia = {
        enable = true;
        animations = false;
      };
    };

    dev = {
      rust = true;
      python = true;
    };

    tools = {
      editors = true;
      graphics = true;
      "3d-printing" = true;
      science = true;
      gaming = true;
    };
  };
}
