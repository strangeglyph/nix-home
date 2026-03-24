{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.glyph.tailscale;
in
{
  options.glyph.tailscale = {
    operator = lib.mkOption {
      description = "tailscaled service user";
      default = "root";
    };
    taildrop = {
      enable = lib.mkEnableOption {
        description = "permanent listening service for incoming taildrop files";
      };
      conflict = lib.mkOption {
        description = "conflict resolution mode for pre-existing files";
        type = lib.types.enum [
          "skip"
          "overwrite"
          "rename"
        ];
        default = "rename";
      };
      directory = lib.mkOption {
        description = "taildrop download directory";
      };
    };
  };

  config = lib.mkMerge [
    ({
      services.tailscale = {
        useRoutingFeatures = "both";
        openFirewall = true;
        extraUpFlags = [
          "--login-server=https://ouroboros.apophenic.net"
          "--operator=${cfg.operator}"
        ];
      };

      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];
    })
    (lib.mkIf cfg.taildrop.enable {
      users.users.${cfg.operator}.linger = true;

      systemd.tmpfiles.settings."10-taildrop" = {
        "${cfg.taildrop.directory}".d = {
          user = cfg.operator;
          group = "nobody";
          mode = "0700";
        };
      };

      systemd.services.taildrop = {
        enable = true;
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        description = "Persistent taildrop download service";

        enableStrictShellChecks = true;

        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getExe pkgs.tailscale} file get --loop --conflict ${cfg.taildrop.conflict} ${cfg.taildrop.directory}";
          User = cfg.operator;
        };
      };
    })
  ];
}
