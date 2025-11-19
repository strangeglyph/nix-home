{ config, pkgs, lib, ... }:
let 
  inherit (lib) mkEnableOption mkIf flip concatMapStrings escapeShellArg;
  restic-auth-files = lib.flatten (config.glyph.transpose-here [ "restic" "auth-files" ]);
  g_restic_server = config.globals.services.restic-server;
  g_headscale = config.globals.services.headscale;
in 
{
  imports = [
    ./acme.nix
  ];

  options.glyph.restic-server = {
    enable = mkEnableOption {};
  };

  config = mkIf config.glyph.restic-server.enable {
    age.secrets."restic-server.htpasswd" = {
      rekeyFile = ../../secrets/sources/restic/.htpasswd.age;
      owner = "restic";
      generator = {
        dependencies = restic-auth-files;
        script = { lib, pkgs, decrypt, deps, ... }: 
          ''
            set -euo pipefail
          '' +
          (flip concatMapStrings deps ({name, host, file}: ''
            echo "Aggregating "''${lib.escapeShellArg host}:''${lib.escapeShellArg name} >&2
            
            auth_data=$(${decrypt} ${escapeShellArg file})
            user=$(echo "$auth_data" | grep "RESTIC_REST_USERNAME" | cut -d'=' -f2)
            pass=$(echo "$auth_data" | grep "RESTIC_REST_PASSWORD" | cut -d'=' -f2)

            echo "$pass" | ${pkgs.apacheHttpd}/bin/htpasswd -inBC 10 "$user"
          ''));
      };
    };

    services.restic.server = {
      enable = true;
      privateRepos = true;
      listenAddress = "${g_headscale.myAddr}:${toString g_restic_server.bindport}";
      htpasswd-file = config.age.secrets."restic-server.htpasswd".path;
      dataDir = "/data/backups";
      appendOnly = true;
      extraFlags = [
        "--tls"
        # not supported in version currently in 25.05
        # TODO wait for update and reenable
        # "--tls-min-ver" "1.3"
        "--tls-cert" "${config.globals.acme.mkChain g_restic_server.domain}"
        "--tls-key" "${config.globals.acme.mkKey g_restic_server.domain}"
      ];
    };

    glyph.transpose.headscale.dns = [
      (g_headscale.mkDnsEntry g_restic_server.host)
    ];

    security.acme.certs.${g_restic_server.domain} = {
      reloadServices = [ "restic-rest-server.service" ];
      group = "restic";
    };
  };
}