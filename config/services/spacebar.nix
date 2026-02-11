{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf;
  gservices = config.globals.services;
  cfg = config.glyph.spacebar;
in
{
  options.glyph.spacebar.enable = lib.mkEnableOption { description = "Spacebar (née Fosscord) server"; };

  config = mkIf cfg.enable {
    security.acme.certs."${gservices.spacebar.domain}" = {
      extraDomainNames = [
        gservices.spacebar.admin-api.domain
        gservices.spacebar.api.domain
        gservices.spacebar.gateway.domain
        gservices.spacebar.cdn.domain
      ];
      reloadServices = [ "nginx.service" ];
      group = "nginx";
    };

    sops.secrets."spacebar/cdnSignature" = {};
    sops.secrets."spacebar/requestSignature" = {};
    
    services.spacebarchat-server = {
      enable = true;
      # not currently supported
      #enableAdminApi = true;
      #enableCdnCs = true;
      serverName = gservices.spacebar.domain;

      cdnSignaturePath = config.sops.secrets."spacebar/cdnSignature".path;
      requestSignaturePath = config.sops.secrets."spacebar/requestSignature".path;
    
      adminApiEndpoint = {
        useSsl = true;
        host = gservices.spacebar.admin-api.domain;
        localPort = gservices.spacebar.admin-api.port;
      };

      apiEndpoint = {
        useSsl = true;
        host = gservices.spacebar.api.domain;
        localPort = gservices.spacebar.api.port;
      };

      gatewayEndpoint = {
        useSsl = true;
        host = gservices.spacebar.gateway.domain;
        localPort = gservices.spacebar.gateway.port;
      };

      cdnEndpoint = {
        useSsl = true;
        host = gservices.spacebar.cdn.domain;
        localPort = gservices.spacebar.cdn.port;
      };

      settings = {
        api = {
          endpointPrivate = "http://${gservices.spacebar.bindaddr}:${toString gservices.spacebar.api.port}";
          endpointPublic = "https://${gservices.spacebar.api.domain}/api/v9";
        };
        cdn = {
          endpointPrivate = "http://${gservices.spacebar.bindaddr}:${toString gservices.spacebar.cdn.port}";
          endpointPublic = "https://${gservices.spacebar.cdn.domain}";
        };
        gateway = {
          endpointPrivate = "http://${gservices.spacebar.bindaddr}:${toString gservices.spacebar.gateway.port}";
          endpointPublic = "wss://${gservices.spacebar.gateway.domain}";
        };
        general = {
          instanceName = "Sate//ite";
          instanceDescription = "A cold, dark, and very gentle place.";
        };
        limits = {
          user = {
            maxUsername = 64;
            maxBio = 1000;
          };
          channel.maxTopic = 10000;
        };
        security = {
          forwardedFor = "X-Forwarded-For";
          trustedProxies = "127.0.0.1";
        };
        register = {
          dateOfBirth.required = false;
          password.required = true;
          disabled = true;
          requireInvite = true;
        };
        rabbitmq.host = "amqp://guest:guest@${config.services.rabbitmq.listenAddress}:${toString config.services.rabbitmq.port}";
        guild = {
          autoJoin = {
            bots = false;
            canLeave = true;
            enabled = true;
            guilds = [ 1470569779143168044 ];
          };
          defaultFeatures = [
            "ALIASABLE_NAMES"
            "VANITY_URL"
            "CROSS_CHANNEL_REPLIES"
            "ANIMATED_ICON"
            "BANNER"
            "GUILD_TAGS"
            "GUILD_SERVER_GUIDE"
            "GUILD_ONBOARDING"
            "MEMBER_PROFILES"
            "NEWS"
            "ROLE_ICONS"
          ];
        };
      };

      extraEnvironment = {
        DATABASE = "postgres://?host=/run/postgresql";
      };
    };

    services.postgresql = let
      serviceUser = config.systemd.services.spacebar-api.serviceConfig.User;
    in {
      enable = true;
      ensureDatabases = [ serviceUser ];
      ensureUsers = [
        {
          name = serviceUser;
          ensureDBOwnership = true;
        }
      ];
    };

    services.rabbitmq = {
      enable = true;
    };

    services.nginx.virtualHosts."${gservices.spacebar.domain}" = gservices.nginx.mkReverseProxy {
      proto = "http";
      domain = gservices.spacebar.bindaddr;
      port = gservices.spacebar.api.port;
      acme_host = gservices.spacebar.domain;
      locationExtraConfig = ''
        add_header Last-Modified $date_gmt;
        add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
        proxy_no_chache 1;
        proxy_cache_bypass 1;
      '';
    } // {
      locations."/.well-known/spacebar" = {
        return = ''
          200 '{"api": "https://api.${gservices.spacebar.domain}/api/v9"}'
        '';
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };

    #services.nginx.virtualHosts.${gservices.spacebar.admin-api.domain} = gservices.nginx.mkReverseProxy {
    #  proto = "http";
    #  domain = gservices.spacebar.bindaddr;
    #  port = gservices.spacebar.admin-api.port;
    #  acme_host = gservices.spacebar.domain;
    #};

    services.nginx.virtualHosts.${gservices.spacebar.api.domain} = gservices.nginx.mkReverseProxy {
      proto = "http";
      domain = gservices.spacebar.bindaddr;
      port = gservices.spacebar.api.port;
      acme_host = gservices.spacebar.domain;
    };

    services.nginx.virtualHosts.${gservices.spacebar.gateway.domain} = gservices.nginx.mkReverseProxy {
      proto = "http";
      domain = gservices.spacebar.bindaddr;
      port = gservices.spacebar.gateway.port;
      acme_host = gservices.spacebar.domain;
    };

    services.nginx.virtualHosts.${gservices.spacebar.cdn.domain} = gservices.nginx.mkReverseProxy {
      proto = "http";
      domain = gservices.spacebar.bindaddr;
      port = gservices.spacebar.cdn.port;
      acme_host = gservices.spacebar.domain;
    };
  };
}