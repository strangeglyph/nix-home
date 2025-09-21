{ pkgs, config, lib, nodes, ... }:
let
  cfg = config.services.kanidm;
  acme = config.security.acme;

  json = pkgs.formats.json {};

  globals = config.globals;

  g_kanidm = globals.services.kanidm;
  domain = g_kanidm.domain;

  globals_hs = globals.services.headscale;

  transposed-kanidm = lib.flatten (config.glyph.transpose-here [ "kanidm" ]);
  transposed-age = lib.catAttrs "age" transposed-kanidm;
  transposed-provision = lib.catAttrs "provision" transposed-kanidm;
  transposed-extra-provision = lib.catAttrs "provision-extra" transposed-kanidm;
in
{
  imports = [ ./nginx-common.nix ];

  options.glyph.kanidm.enable = lib.mkEnableOption {};
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

    users.groups.acme.members = [ "kanidm" ];

    age = lib.mkMerge transposed-age;

    services.kanidm = {
      package = pkgs.kanidmWithSecretProvisioning;

      enableClient = true;
      clientSettings = {
        uri = cfg.serverSettings.origin;
      };

      enableServer = true; 
      serverSettings = {
        bindaddress = "${g_kanidm.bindaddr}:${toString g_kanidm.bindport}";
        ldapbindaddress = "${g_kanidm.bindaddr}:${toString g_kanidm.ldapbindport}";
        trust_x_forward_for = true;
        domain = domain;
        origin = "https://${domain}";
        tls_chain = globals.acme.chain;
        tls_key = globals.acme.key;
      };

      provision = lib.mkMerge ([{
        enable = false;

        persons = {
          "glyph" = {
            displayName = "glyph";
            mailAddresses = [ "interstice@mail.apophenic.net" ];
            groups = [ 
              "interstice_users"
            ];
          };
        };
        groups = {
          "interstice_users" = {};
        };
        systems.oauth2 = {
          "interstice" = {
            displayName = "Interstice";
            originUrl = "https://${globals_hs.domain}/oidc/callback";
            originLanding = "https://${globals_hs.domain}/";
            basicSecretFile = config.age.secrets.kanidm_oauth_interstice.path;
            preferShortUsername = true;
            scopeMaps."interstice_users" = [ "openid" "email" "profile" ];
          };
        };
        extraJsonFile = json.generate "kanidm_extra_provision.json" (lib.mkMerge transposed-extra-provision);
      }] ++ transposed-provision);
    };

    services.nginx = {
      enable = true;
      virtualHosts."${domain}" = globals.services.nginx.mkReverseProxy {
        domain = g_kanidm.bindaddr;
        port = g_kanidm.bindport;
      };
    };
  };
}
