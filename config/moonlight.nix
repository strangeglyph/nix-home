{ pkgs, ... }:
let
in
{
  imports = [
    ./services
  ];

  glyph = {
    users.glyph = {
      privileged = true;
      with-pw = true;
    };

    restic-server.enable = true;
    monitoring.grafana.enable = true;
    immich.enable = true;
  };

  services = {
    postgresql.package = pkgs.postgresql_18;
  };

  services = {
    postgresql.package = pkgs.postgresql_18;
  };
}
