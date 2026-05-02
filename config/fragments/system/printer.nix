{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    join
    ;
  cfg = config.glyph.printer;
in
{
  options.glyph.printer = {
    enable = mkOption {
      description = "Enable printer and scanner tools";
      default = cfg.remotes != [ ];
      type = types.bool;
    };
    remotes = mkOption {
      description = "Addresses of the remote printer queues";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    # Scanner interface
    hardware.sane.enable = true;

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        epson-escpr
      ];
      browsedConf = lib.optionalString (cfg.remotes != [ ]) ''
        CreateRemoteRawPrinterQueues Yes
        ${join "\n" (map (remote: "BrowsePoll ${remote}") cfg.remotes)}
      '';
    };

    # LAN printer discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
