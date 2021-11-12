{ config, pkgs, lib, ... }:
{
  systemd.services.fompf = {
    enable = true;
    description = "Discord Forwarder";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    unitConfig = {
      Type = "simple";
    };

    serviceConfig = {
      WorkingDirectory = "/home/fompf/fompf";
      User = "fompf";
      Restart = "always";
      ExecStart = "${pkgs.pipenv}/bin/pipenv run python main.py";
      Environment = "PATH=/run/current-system/sw/bin";
    };
  };
}
