{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.kanidm;

  json = pkgs.formats.json { };

  globals = config.globals;

  g_kanidm = globals.services.kanidm;
  domain = g_kanidm.domain;

  globals_hs = globals.services.headscale;

  transposed-kanidm = lib.flatten (config.glyph.transpose-here [ "kanidm" ]);
  transposed-age = lib.catAttrs "age" transposed-kanidm;
  transposed-sops = lib.catAttrs "sops" transposed-kanidm;
  transposed-provision = lib.catAttrs "provision" transposed-kanidm;
  transposed-extra-provision = json.type.merge { } (
    lib.map (x: { value = x; }) (lib.catAttrs "provision-extra" transposed-kanidm)
  );
in
{
  imports = [
    ./nginx-common.nix
  ];

  options.glyph.kanidm.enable = lib.mkEnableOption { };
  options.glyph.kanidm.crossProvision = lib.mkOption {
    type = lib.types.attrOf lib.types.anything;
  };

  config = lib.mkIf config.glyph.kanidm.enable {
    assertions = [
      {
        assertion = (config.networking.hostName == g_kanidm.machine);
        message = ''
          You are trying to provision the unique service `kanidm` on machine ${config.networking.hostName},
          but it is registered as being hosted on machine ${g_kanidm.machine}.
        '';
      }
    ];

    users.groups.kanidm-certs.members = [
      "kanidm"
      "acme"
      "nginx"
    ];
    security.acme.certs.${g_kanidm.domain} = {
      reloadServices = [ "kanidm.service" ];
      group = "kanidm-certs";
      extraDomainNames = [ g_kanidm.vpn_domain ];
    };

    age = lib.mkMerge transposed-age;
    sops = lib.mkMerge transposed-sops;

    networking.firewall.interfaces."${config.services.tailscale.interfaceName}" = {
      allowedTCPPorts = [ g_kanidm.ldapbindport ];
      allowedUDPPorts = [ g_kanidm.ldapbindport ];
    };

    glyph.transpose.headscale.dns = [
      (config.globals.services.headscale.mkDnsEntry g_kanidm.host)
    ];

    services.kanidm = {
      package = pkgs.kanidmWithSecretProvisioning_1_10;

      client = {
        enable = true;
        settings = {
          uri = cfg.server.settings.origin;
        };
      };

      server = {
        enable = true;
        settings = {
          bindaddress = "${g_kanidm.bindaddr}:${toString g_kanidm.bindport}";
          ldapbindaddress = "${globals.services.headscale.myAddr}:${toString g_kanidm.ldapbindport}";

          http_client_address_info = {
            x-forward-for = [
              "127.0.0.1"
              "::1"
            ];
          };

          domain = domain;
          origin = "https://${domain}";
          tls_chain = globals.acme.mkChain g_kanidm.domain;
          tls_key = globals.acme.mkKey g_kanidm.domain;

          online_backup = {
            path = "/var/backups/kanidm";
            schedule = "13 * * * *";
            versions = 1;
          };
        };
      };

      provision = lib.mkMerge (
        [
          {
            enable = true;
            # see https://github.com/oddlama/kanidm-provision/issues/26#issuecomment-3232578427
            instanceUrl = "https://${cfg.server.settings.bindaddress}";
            acceptInvalidCerts = true;

            persons = {
              "glyph" = {
                displayName = "glyph";
                mailAddresses = [ config.glyph.confidentials.emails.kanidm.glyph ];
                groups = [
                  "interstice_users"
                  "forgejo_users"
                  "forgejo_admins"
                  "paperless_users"
                  "paperless_admins"
                  "actualbudget_users"
                ];
              };
              "o" = {
                displayName = config.glyph.confidentials.displayNames.kanidm.o;
                mailAddresses = [ config.glyph.confidentials.emails.kanidm.o ];
                groups = [
                  "interstice_users"
                ];
              };
              "h" = {
                displayName = config.glyph.confidentials.displayNames.kanidm.h;
                mailAddresses = [ config.glyph.confidentials.emails.kanidm.h ];
                groups = [
                  "interstice_users"
                ];
              };
              "m" = {
                displayName = config.glyph.confidentials.displayNames.kanidm.m;
                mailAddresses = [ config.glyph.confidentials.emails.kanidm.m ];
                groups = [
                  "interstice_users"
                ];
              };
              "g" = {
                displayName = config.glyph.confidentials.displayNames.kanidm.g;
                mailAddresses = [ config.glyph.confidentials.emails.kanidm.g ];
                groups = [
                  "interstice_users"
                ];
              };
            };
            groups = {
              "interstice_users" = { };
              "forgejo_users" = { };
              "forgejo_admins" = { };
              "paperless_users" = { };
              "paperless_admins" = { };
              "actualbudget_users" = { };
            };
            systems.oauth2 = {
              "interstice" = {
                displayName = "Interstice";
                originUrl = "https://${globals_hs.domain}/oidc/callback";
                originLanding = "https://${globals_hs.domain}/";
                basicSecretFile = config.age.secrets.kanidm_oauth_interstice.path;
                preferShortUsername = true;
                scopeMaps."interstice_users" = [
                  "openid"
                  "email"
                  "profile"
                ];
                imageFile = ../../assets/headscale3-dots.svg;
              };
            };
            extraJsonFile = json.generate "kanidm_extra_provision.json" transposed-extra-provision;
          }
        ]
        ++ transposed-provision
      );
    };

    glyph.transpose.kanidm = [
      {
        provision-extra = {
          persons.glyph.groups = [
            "idm_admins"
            "idm_people_self_mail_write"
          ];
          persons.o.groups = [
            "idm_people_self_mail_write"
          ];
          persons.h.groups = [
            "idm_people_self_mail_write"
          ];
          persons.m.groups = [
            "idm_people_self_mail_write"
          ];
          persons.g.groups = [
            "idm_people_self_mail_write"
          ];
        };
      }
    ];

    services.nginx = {
      enable = true;
      virtualHosts."${domain}" = globals.services.nginx.mkReverseProxy {
        domain = g_kanidm.bindaddr;
        port = g_kanidm.bindport;
        acme_host = g_kanidm.domain;
      };
    };

    glyph.restic.kanidm.paths = [ "/var/backups/kanidm" ];
  };
}
