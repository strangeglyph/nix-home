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
        "${config.networking.hostName}/${n}/nextcloud/user" = { };
        "${config.networking.hostName}/${n}/nextcloud/pass" = { };
      })
      |> zipAttrsWith (
        _: vals:
        assert (length vals == 1);
        head vals
      );

    sops.templates =
      glib.humanUsers
      |> filter (n: config.glyph.users.${n}.wallpaper.sync.enable)
      |> map (n: {
        "${config.networking.hostName}/${n}/nextcloud/env".content = ''
          NC_USER=${config.sops.placeholder."${config.networking.hostName}/${n}/nextcloud/user"}
          NC_PASSWORD=${config.sops.placeholder."${config.networking.hostName}/${n}/nextcloud/pass"}
        '';
      })
      |> zipAttrsWith (
        _: vals:
        assert (length vals == 1);
        head vals
      );

    home-manager.users = glib.eachHumanUser (
      name: cfg: hm-args:
      mkIf (cfg.wallpaper.sync.enable) {
        systemd.user = {
          services.wallpaper-autosync = {
            Unit = {
              Description = "Sync ~/Wallpapers to nextcloud";
              After = "network-online.target";
            };
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.nextcloud-client}/bin/nextcloudcmd --non-interactive --path /Wallpapers '${hm-args.config.home.homeDirectory}/Wallpapers' https://${config.services.nextcloud.hostName}";
              TimeoutStopSec = "180";
              KillMode = "process";
              KillSignal = "SIGINT";
              EnvironmentFile = config.sops.templates."${config.networking.hostName}/${name}/nextcloud/env".path;
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
