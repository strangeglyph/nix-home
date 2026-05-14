{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    types
    filter
    zipAttrsWith
    length
    head
    ;
  inherit (config) glib;
in
{
  options.glyph.users = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          wallpaper = {
            sync = {
              enable = mkOption {
                description = ''
                  Sync wallpaper folder with nextcloud.

                  Ensure sops secrets for <hostname>/<username>/nextcloud/user 
                  and <hostname>/<username>/nextcloud/pass are provided.
                '';
                default = false;
                type = types.bool;
              };
            };
          };
        };
      }
    );
  };

  config = {
    sops.secrets =
      glib.humanUsers
      |> filter (n: config.glyph.users.${n}.wallpaper.sync.enable)
      |> map (n: {
        "${config.networking.hostName}/${n}/nextcloud/user" = {
          owner = n;
        };
        "${config.networking.hostName}/${n}/nextcloud/pass" = {
          owner = n;
        };
      })
      |> zipAttrsWith (
        _: vals:
        assert (length vals == 1);
        head vals
      );

    home-manager.users = glib.eachHumanUser (
      name: cfg: hm-args:
      mkIf (cfg.wallpaper.sync.enable) {
        systemd.user.tmpfiles.rules = [
          "d ${hm-args.config.home.homeDirectory}/Wallpapers 0700 ${name} - - -"
        ];

        systemd.user = {
          services.wallpaper-autosync = {
            Unit = {
              Description = "Sync ~/Wallpapers to nextcloud";
              After = "network-online.target";
            };
            Service = {
              ExecStart = pkgs.writeShellScript "wallpaper-sync" ''
                export NC_USER="$(cat $CREDENTIALS_DIRECTORY/user)"
                export NC_PASSWORD="$(cat $CREDENTIALS_DIRECTORY/pass)"

                ${pkgs.nextcloud-client}/bin/nextcloudcmd \
                  --non-interactive \
                  --path /Wallpapers '${hm-args.config.home.homeDirectory}/Wallpapers' \
                  https://${config.globals.services.nextcloud.domain}
              '';
              Type = "simple";
              TimeoutStopSec = "180";
              KillMode = "process";
              KillSignal = "SIGINT";
              LoadCredential = [
                "user:${config.sops.secrets."${config.networking.hostName}/${name}/nextcloud/user".path}"
                "pass:${config.sops.secrets."${config.networking.hostName}/${name}/nextcloud/pass".path}"
              ];
            };
            Install.WantedBy = [ "multi-user.target" ];
          };
          timers.wallpaper-autosync = {
            Unit.Description = "Sync ~/Wallpapers to nextcloud";
            Timer = {
              OnBootSec = "5min";
              OnUnitActiveSec = "60min";
            };
            Install.WantedBy = [
              "multi-user.target"
              "timers.target"
            ];
          };
          startServices = true;
        };
      }
    );
  };
}
