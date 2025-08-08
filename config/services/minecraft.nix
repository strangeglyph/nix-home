{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.minecraft;
in
{
  options.glyph.minecraft = {
    enable = mkEnableOption "minecraft service";
  };

  config = mkIf config.glyph.minecraft.enable {
    networking.firewall.allowedTCPPorts = [ config.globals.services.minecraft.port ];

    systemd.services.minecraft = {
      enable = true;
      description = "Minecraft Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        WorkingDirectory = "/home/minecraft/minecraft";
        User = "minecraft";
        # See https://www.reddit.com/r/feedthebeast/comments/5jhuk9/modded_mc_and_memory_usage_a_history_with_a/
        ExecStart = "${pkgs.temurin-jre-bin}/bin/java -Xms2g -Xmx4g -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M @libraries/net/minecraftforge/forge/1.20.1-47.4.0/unix_args.txt";
        ExecStop = "/bin/bash -c \"/bin/echo stop > /home/minecraft/minecraft/minecraft.sock\"";
        Restart = "on-failure";
        RestartSec = "15s";

        Environment = "PATH=/run/current-system/sw/bin";

        Sockets = "minecraft.socket";
        StandardInput = "socket";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.sockets.minecraft = {
      enable = true;
      bindsTo = [ "minecraft.service" ];
      
      socketConfig = {
        Service = "minecraft.service";
        ListenFIFO = "/home/minecraft/minecraft/minecraft.sock";
        SocketUser = "minecraft";
        SocketMode = "0200";
        RemoveOnStop = true;
      };
    };
  };
}
