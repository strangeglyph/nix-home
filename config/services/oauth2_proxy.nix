{ pkgs, config, lib, nodes, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.glyph.nginx.oauth2-gate;

  globals = config.globals;
  globals_o2p = globals.services.oauth2-proxy;

  kanidm_host = globals.services.kanidm.machine;

  mkClientId = vhost: "oauth2-proxy_${vhost}";
  mkTransposedBasicSecretRef = vhost: nodes."${kanidm_host}".config.age.secrets."kanidm_basic_secret_${mkClientId vhost}";
in
{
  options.glyph.nginx.oauth2-gate = lib.mkOption {
    description = "Create a containerized oauth2-instance that gates access to a vhost";
    default = {};
    type = types.attrsOf (types.submodule {
      port = mkOption { type = types.port; };
      displayName = mkOption { type = types.nullOr types.str; default = null; };
    });
  };

  config.assertions = lib.optional (cfg != {}) {
    assertion = nodes."${kanidm_host}".services.kanidm.enable;
    message = ''
      You are trying to gate one or more vhosts behind oauth, but kanidm isn't marked as enabled
      on machine ${kanidm_host}.
    '';
  };

  config.glyph.transpose.kanidm = lib.mapAttrsToList (vhost: settings: {
    age.secrets."kanidm_basic_secret_${mkClientId vhost}" = {
      rekeyFile = ../agenix/kanidm/basic_secret_${mkClientId vhost};
      owner = "kanidm";
      generator.script = "alnum";
    };
    provision.systems.oauth2."${mkClientId vhost}" = {
      displayName = "${settings.displayName}";
      originUrl = "https://${vhost}";
      originLanding = "https://${vhost}";
      basicSecretFile = (mkTransposedBasicSecretRef vhost).path;
    };
    provision-extra = {
      # needed for idm_all_persons
      systems.oauth2."${mkClientId vhost}" = {
        scopeMaps."idm_all_persons" = [ "openid" "email" "groups" ];
        claimMaps."groups".valuesByGroup = {
          idm_all_persons = "access";
        };
      };
    };
  }) cfg;

  config.age.secrets = mkMerge (lib.mapAttrsToList (vhost: settings: {
    "oauth2-proxy_secrets_${vhost}" = {
      rekeyFile = ../agenix/oauth2-proxy/oauth2-proxy_secrets_${vhost};
      owner = "oauth2-proxy";
      generator = {
        dependencies.basic_secret = mkTransposedBasicSecretRef vhost;
        script = { lib, pkgs, decrypt, deps, ... }: ''
          printf 'OAUTH2_PROXY_CLIENT_SECRET="%s"\n' $(${decrypt} ${lib.escapeShellArg deps.basic_secret.file})
          printf 'OAUTH2_PROXY_COOKIE_SECRET="%s"\n' $(${lib.getExe pkgs.openssl} rand -base64 32)
        '';
      };
    };
  }) cfg);

  config.containers = mkMerge (lib.mapAttrsToList (vhost: settings: { 
    containers."oauth2-proxy_${vhost}".config = { container-config, pkgs, ... }: {
      services.oauth2-proxy = {
        enable = true;
        provider = "oidc";
        clientID = mkClientId vhost;
        keyFile = config.age.secrets."oauth2-proxy_secrets_${vhost}".path;
        httpAddress = "http://[::1]:${toString settings.port}";
        redirectURL = "https://auth.${vhost}/oauth2/callback";
        oidcIssuerUrl = globals.services.kanidm.makeOidc (mkClientId vhost);
        scope = "openid email";
        email.domains = [ "*" ];

        extraConfig = {
          provider-display-name = "[ 門 ]";
          code-challenge-method = "S256";
        };
      };
      system.stateVersion = "25.05";
    };
  }) cfg);

      #nginx = {
      #  domain = globals_o2p.domain;
      #  virtualHosts."oauth2-test.apophenic.net".allowed_groups = [ "access" ];
      #};

    #services.nginx.virtualHosts = {
    #  "${globals_o2p.domain}" = globals.services.nginx.mkDefault {};
    #  "oauth2-text.apophenic.net" = {
    #    locations."/" = {
    #      root = builtins.toFile "index.html" "You just got authed!";
    #    };
    #  };
    #};
}
