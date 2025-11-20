{ config, lib, pkgs, ... }:
let
  inherit (lib) mapAttrsToList flip mkOption mkMerge types;
  g_restic_server = config.globals.services.restic-server;
in
{
  options.glyph.restic = mkOption {
    description = "Create a restic repo <name>";
    default = {};
    type = types.attrsOf (types.submodule {
      options = {
        paths = mkOption {
          description = "List of paths to back up to this repo";
          type = types.listOf types.str;
        };
        extra = mkOption {
          description = "Extra config";
          type = types.attrsOf types.anything;
          default = {};
        };
      };
    });
  };
  
  config = {
    users = {
      users.restic = {
        group = "restic";
        isSystemUser = true;
      };
      groups.restic = {};
    };

    security.wrappers.restic = {
      source = lib.getExe pkgs.restic;
      owner = "restic";
      group = "restic";
      permissions = "500"; # or u=rx,g=,o=
      capabilities = "cap_dac_read_search+ep";
    };

    age.secrets = mkMerge (flip mapAttrsToList config.glyph.restic (repo-name: _: {
      "restic_auth_${repo-name}" = {
        rekeyFile = ../../secrets/sources/restic/repo_auth_${repo-name}.age;
        owner = "restic";
        generator = {
          script = { lib, pkgs, decrypt, deps, ... }: ''
            printf 'RESTIC_REST_USERNAME="${repo-name}"\n'
            printf 'RESTIC_REST_PASSWORD="%s"\n' $(${lib.getExe pkgs.openssl} rand -base64 48 | tr -- '+/' '-_')
          '';
        };
      };
      "restic_crypt_${repo-name}" = {
        rekeyFile = ../../secrets/sources/restic/repo_crypt_${repo-name}.age;
        owner = "restic";
        generator.script = "alnum";
      };
    }));

    glyph.transpose.restic.auth-files = flip mapAttrsToList config.glyph.restic 
      (repo-name: _: config.age.secrets."restic_auth_${repo-name}");

    services.restic.backups = mkMerge (flip mapAttrsToList config.glyph.restic (repo-name: settings: {
      "${repo-name}" = {
        user = "restic";
        package = pkgs.writeShellScriptBin "restic" ''
          exec /run/wrappers/bin/restic "$@"
        '';
        repository = "rest:https://${g_restic_server.domain}:${toString g_restic_server.bindport}/${repo-name}";
        initialize = true;
        paths = settings.paths;
        passwordFile = config.age.secrets."restic_crypt_${repo-name}".path;
        environmentFile = config.age.secrets."restic_auth_${repo-name}".path;
      } // settings.extra;
    }));
  };
}