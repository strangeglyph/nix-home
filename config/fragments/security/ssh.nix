{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkMerge
    types
    ;
  gservices = config.globals.services;
  default-keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRwfYnEBA8Pdsqui9xxLkk7KYpKjA01YvzHx8Sfe1PW lschuetze@aeolus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFCfbpXsvpFUdCa6QL9PMloDtbTyqvvxLML7o/7w2Pi glyph@rosetta"
  ];
in
{
  options.glyph = {

    ssh = {
      enable = mkOption {
        description = "Enable sshd";
        default = true;
        type = types.bool;
      };
    };

    users = mkOption {
      type = types.attrsOf (
        types.submodule {
          options.pubkeys = mkOption {
            description = "SSH keys with login privileges";
            default = default-keys;
            type = types.listOf types.str;
          };
        }
      );
    };
  };

  config = mkIf config.glyph.ssh.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      allowSFTP = false;

      extraConfig = lib.mkAfter ''
        Match Address ${gservices.headscale.address_space}
            PermitRootLogin yes
      '';
    };

    users.users = mkMerge [
      (config.glib.eachHumanUser (
        name: cfg: {
          openssh.authorizedKeys.keys = cfg.pubkeys;
        }
      ))
      {
        root.openssh.authorizedKeys.keys = default-keys;
      }
    ];
  };
}
