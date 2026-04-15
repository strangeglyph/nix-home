{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.glyph.tailscale;
in
{
  options.glyph.tailscale = {
    enable = mkOption {
      description = "Enable tailscale";
      default = true;
      type = types.bool;
    };

    operator = mkOption {
      description = "User operator for tailscale";
      default = "root";
      type = types.str;
    };

    taildrop = {
      enable = mkOption {
        description = "Enable taildrop listen service";
        default = cfg.operator != "root";
        type = types.bool;
      };
      directory = mkOption {
        description = "Taildrop target directory";
        default = "/home/${cfg.operator}/Downloads/taildrop";
        type = types.path;
      };
      conflict = mkOption {
        description = "Conflict resolution behavior";
        default = "rename";
        type = types.enum [
          "rename"
          "skip"
          "overwrite"
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      openFirewall = true;
      extraUpFlags = [
        "--login-server=https://${config.globals.headscale.domain}"
        "--operator=${cfg.operator.operator}"
      ];
    };

    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    systemd.tmpfiles.settings."10-taildrop" = mkIf cfg.taildrop.enable {
      "${cfg.taildrop.directory}".d = {
        user = cfg.operator;
        group = "nobody";
        mode = "0700";
      };
    };

    systemd.services.taildrop = mkIf cfg.taildrop.enable (
      config.glib.systemd.mkParanoid { }
        {
          DynamicUser = false;
          ProtectHome = false;
        }
        {
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
        }
    );
  };
}
