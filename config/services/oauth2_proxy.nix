{ pkgs, config, lib, nodes, name, inputs, ... }:
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
    description = "Create a containerized oauth2-instance that gates access to vhost <name>";
    default = {};
    type = types.attrsOf (types.submodule {
      options = {
        port = mkOption { type = types.port; description = "port to bind this oauth2-proxy instance to"; };
        displayName = mkOption { type = types.str; };
        allowed_groups = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          description = "List of groups to allow access to this vhost, or null to allow all.";
          default = null;
        };
        allowed_emails = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          description = "List of emails to allow access to this vhost, or null to allow all.";
          default = null;
        };
        allowed_email_domains = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          description = "List of email domains to allow access to this vhost, or null to allow all.";
          default = null;
        };
      };
    });
  };

  config.assertions = lib.optional (cfg != {}) {
    assertion = nodes."${kanidm_host}".config.glyph.kanidm.enable;
    message = ''
      You are trying to gate one or more vhosts behind oauth, but kanidm isn't marked as enabled
      on machine ${kanidm_host}.
    '';
  };

  config.glyph.transpose.kanidm = lib.mapAttrsToList (vhost: settings: {
    age.secrets."kanidm_basic_secret_${mkClientId vhost}" = {
      rekeyFile = ../../secrets/sources/kanidm/basic_secret_${mkClientId vhost}.age;
      owner = "kanidm";
      generator.script = "alnum";
    };
    provision.systems.oauth2."${mkClientId vhost}" = {
      displayName = "${settings.displayName}";
      originUrl = "https://auth.${vhost}/oauth2/callback";
      originLanding = "https://${vhost}";
      basicSecretFile = (mkTransposedBasicSecretRef vhost).path;
    };
    provision-extra = {
      # needed for idm_all_persons
      systems.oauth2."${mkClientId vhost}" = {
        scopeMaps."idm_all_persons" = [ "openid" "email" "groups" ];
      };
    };
  }) cfg;

  config.users.users.oauth2-proxy = {
    description = "OAuth2 Proxy";
    isSystemUser = true;
    group = "oauth2-proxy";
    uid = config.globals.services.oauth2-proxy.uid;
  };

  config.users.groups.oauth2-proxy.gid = config.globals.services.oauth2-proxy.gid;
  config.users.groups.oauth2-proxy-cert-access = {
    gid = config.globals.services.oauth2-proxy.cert-group-gid;
    members = [ 
      "oauth2-proxy"
      "nginx"
    ];
  };

  config.age.secrets = mkMerge (lib.mapAttrsToList (vhost: settings: {
    "oauth2-proxy_secrets_${vhost}" = {
      rekeyFile = ../../secrets/sources/oauth2-proxy/oauth2-proxy_secrets_${vhost}.age;
      owner = "oauth2-proxy";
      generator = {
        dependencies.basic_secret = mkTransposedBasicSecretRef vhost;
        script = { lib, pkgs, decrypt, deps, ... }: ''
          printf 'OAUTH2_PROXY_CLIENT_SECRET="%s"\n' $(${decrypt} ${lib.escapeShellArg deps.basic_secret.file})
          printf 'OAUTH2_PROXY_COOKIE_SECRET="%s"\n' $(${lib.getExe pkgs.openssl} rand -base64 24 | tr -- '+/' '-_')
        '';
      };
    };
  }) cfg);

  config.containers = mkMerge (lib.mapAttrsToList (vhost: settings: { 
    "oauth2-proxy---${lib.replaceStrings ["." "_"] ["--" "-"] vhost}" = {
      
      bindMounts."${config.age.secrets."oauth2-proxy_secrets_${vhost}".path}".isReadOnly = true;
      bindMounts."${config.globals.acme.mkChain "auth.${vhost}"}".isReadOnly = true;
      bindMounts."${config.globals.acme.mkKey "auth.${vhost}"}".isReadOnly = true;
      autoStart = true;

      config = { container-config, pkgs, ... }: {

        users.users.oauth2-proxy.uid = config.users.users.oauth2-proxy.uid;
        users.groups.oauth2-proxy.gid = config.users.groups.oauth2-proxy.gid;
        users.groups.oauth2-proxy-cert-access = {
          members = ["oauth2-proxy"];
          gid = config.globals.services.oauth2-proxy.cert-group-gid;
        };

        services.oauth2-proxy = {
          enable = true;

          tls = {
            enable = true;
            key = config.globals.acme.mkKey "auth.${vhost}";
            certificate = config.globals.acme.mkChain "auth.${vhost}";
            httpsAddress = "https://[::1]:${toString settings.port}";
          };

          cookie.domain = ".${vhost}";

          provider = "oidc";
          clientID = mkClientId vhost;
          keyFile = config.age.secrets."oauth2-proxy_secrets_${vhost}".path;
          # httpAddress = "http://[::1]:${toString settings.port}";
          redirectURL = "https://auth.${vhost}/oauth2/callback";
          oidcIssuerUrl = globals.services.kanidm.makeOidc (mkClientId vhost);
          scope = "openid email";
          email.domains = [ "*" ];

          extraConfig = {
            provider-display-name = "[-門-]";
            code-challenge-method = "S256";
            reverse-proxy = true;
            whitelist-domain = "${vhost}";
          };
        };
        system.stateVersion = "25.05";
      };
    };
  }) cfg);

  config.security.acme.certs = mkMerge (lib.mapAttrsToList (vhost: _: {
    "auth.${vhost}".group = "oauth2-proxy-cert-access";
  }) cfg);

  # cf. https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/security/oauth2-proxy-nginx.nix
  # overview:https://typst.app/
  # for every protected vhost `vhost`:
  # - auth.${vhost} is the reverse proxy endpoint for oauth2-proxy
  # - ${vhost} sets auth_request to ${vhost}/oauth2/auth and redirects 401 to auth.${vhost}/oauth/start
  # - ${vhost}/oauth2/auth is a reverse proxy endpoint for oauth2-proxy/oauth2/auth
  config.services.nginx = mkMerge (lib.mapAttrsToList (vhost: settings: {
    recommendedProxySettings = true;

    virtualHosts."auth.${vhost}" = config.globals.services.nginx.mkReverseProxy { 
      proto = "https";
      port = settings.port;
      acme_host = null;
    } // {
      locations."/oauth2/" = {
        proxyPass = "https://[::1]:${toString settings.port}";
        extraConfig = ''
          auth_request off;
          proxy_set_header X-Scheme                $scheme;
          proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
        '';
      };
    };

    virtualHosts."${vhost}" = {
      locations = {
        "/".extraConfig = ''
          # pass information via X-User and X-Email headers to backend, requires running with --set-xauthrequest flag
          proxy_set_header X-User  $user;
          proxy_set_header X-Email $email;

          # if you enabled --cookie-refresh, this is needed for it to work with auth_request
          add_header Set-Cookie $auth_cookie;
        '';

        "= /oauth2/auth" = 
        let
          maybeQueryArg =
            name: value:
            if value == null then
              null
            else
              "${name}=${lib.concatStringsSep "," (builtins.map lib.escapeURL value)}";
          allArgs = lib.mapAttrsToList maybeQueryArg {
            inherit (settings) allowed_groups allowed_emails allowed_email_domains;
          };
          cleanArgs = builtins.filter (x: x != null) allArgs;
          cleanArgsStr = lib.concatStringsSep "&" cleanArgs;
        in 
        {
          proxyPass = "https://[::1]:${toString settings.port}/oauth2/auth?${cleanArgsStr}";
          extraConfig = ''
            internal;
            auth_request off;
            proxy_set_header X-Scheme         $scheme;
            # nginx auth_request includes headers but not body
            proxy_set_header Content-Length   "";
            proxy_set_header X-Original-URI   $request_uri;
            proxy_pass_request_body           off;
          '';
        };

        "@redirectToAuth2ProxyLogin" = {
          return = "307 https://auth.${vhost}/oauth2/start?rd=$scheme://$host$request_uri";
          extraConfig = ''
            auth_request off;
          '';
        };
      };

      extraConfig = ''
        auth_request /oauth2/auth;
        error_page 401 = @redirectToAuth2ProxyLogin;

        # set variables being used in locations."/".extraConfig
        auth_request_set $user   $upstream_http_x_auth_request_user;
        auth_request_set $email  $upstream_http_x_auth_request_email;
        auth_request_set $auth_cookie $upstream_http_set_cookie;
      '';
    };
  }) cfg);
}
