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

    home-assistant.enable = true;
    restic-server.enable = true;
    monitoring.grafana.enable = true;
    monitoring.prometheus.enable = true;
    immich.enable = true;
  };

  services = {
    postgresql.package = pkgs.postgresql_18;
  };

  services = {
    postgresql.package = pkgs.postgresql_18;
  };
}
