{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.headscale;
  globals = config.globals;
  globals_hs = globals.services.headscale;
  headscale-dns-entries = lib.flatten (config.glyph.transpose-here [ "headscale" "dns" ]);
in
{
  imports = [
    ./nginx-common.nix
  ];

  options.glyph.headscale.enable = mkEnableOption {};

  config = mkIf config.glyph.headscale.enable {
    users.groups.acme.members = [ "headscale" ];
    
    age.secrets.kanidm_oauth_interstice = {
      rekeyFile = ../../secrets/sources/kanidm/basic_secret_interstice.age;
      group = "oauth_interstice";
      mode = "0440";
      generator.script = "alnum";
    };
    
    users.groups = {
      oauth_interstice.members = [ "headscale" "kanidm" ];
    };

    # for self-hosted DERP
    #networking.firewall.allowedUDPPorts = [ 3478 ];

    services.headscale = {
      enable = true;
      address = globals_hs.bindaddr;
      port = globals_hs.bindport;
      settings = {
        server_url = "https://${globals_hs.domain}";
        tls_cert_path = globals.acme.chain;
        tls_key_path = globals.acme.key;
        dns = {
          base_domain = "${globals_hs.net.domain}";
          extra_records = headscale-dns-entries;
          override_local_dns = false;
        };
        oidc = {
          client_secret_path = config.age.secrets.kanidm_oauth_interstice.path;
          client_id = globals_hs.net.name;
          issuer = globals.services.kanidm.makeOidc globals_hs.net.name;
          pkce.enabled = true;
        };
      };
    };


    services.nginx = {
      enable = true;
      virtualHosts."${globals_hs.domain}" = {
        forceSSL = true;
        useACMEHost = globals.domains.base;
        
        quic = true;
        http3 = true;
        # advertise quic support
        extraConfig = ''
          add_header Alt-Svc 'h3=":$server_port"; ma=86400';
        '';


        locations."/" = {
          proxyPass = "https://${globals_hs.bindaddr}:${toString globals_hs.bindport}";
          proxyWebsockets = true;
        };
      };
    };

    ## ---- backup

    systemd.tmpfiles.settings."10-headscale"."/var/backups/headscale".d = {
      user = "headscale";
      group = "headscale";
      mode = "0700";
    };

    glyph.restic.headscale = {
      paths = [ "/var/backups/headscale" ];
      extra.backupPrepareCommand = ''
        set -euo pipefail
        ${lib.getExe pkgs.sqlite} "${cfg.settings.database.sqlite.path}" ".backup /var/backups/headscale/db.sqlite"
        cp "${cfg.settings.noise.private_key_path}" /var/backups/headscale/noise_private.key
      '';
    };

  };
}

