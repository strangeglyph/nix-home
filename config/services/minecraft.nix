{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.minecraft;
in
{
  options.services.minecraft = {
    enable = mkEnableOption "minecraft service";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      adoptopenjdk-jre-hotspot-bin-15
    ];

    networking.firewall.allowedTCPPorts = [ 25565 ];

    systemd.services.minecraft = {
      enable = true;
      description = "Minecraft Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        WorkingDirectory = "/home/minecraft/minecraft";
        User = "minecraft";
        Restart = "always";
        #Type = "forking";
        # See https://www.reddit.com/r/feedthebeast/comments/5jhuk9/modded_mc_and_memory_usage_a_history_with_a/
        ExecStart = "${pkgs.adoptopenjdk-jre-hotspot-bin-8}/bin/java -Xms2g -Xmx4g -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -jar forge.jar";
        #ExecStop = "${pkgs.screen}/bin/screen -p 0 -S minecraft -X eval 'stuff \"stop\"\\015'";
        Environment = "PATH=/run/current-system/sw/bin";
      };
    };
  };
}
