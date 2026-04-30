{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
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
            default = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRwfYnEBA8Pdsqui9xxLkk7KYpKjA01YvzHx8Sfe1PW lschuetze@aeolus"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFCfbpXsvpFUdCa6QL9PMloDtbTyqvvxLML7o/7w2Pi glyph@rosetta"
            ];
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
    };

    users.users = config.glib.eachHumanUser (
      name: cfg: {
        openssh.authorizedKeys.keys = cfg.pubkeys;
      }
    );
  };
}
