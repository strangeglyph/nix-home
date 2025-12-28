{ pkgs, lib, config, nodes, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption mkMerge;
  gservices = config.globals.services;
  cfg = config.glyph.media;
  jellar-post-setup-vars = {
    SSO_CONFIG = builtins.toJSON {
      oidEndpoint = "https://${gservices.kanidm.domain}/oauth2/openid/jellyfin"; 
      oidClientId = "jellyfin"; 
      oidSecret = "placeholder"; 
      enabled =  true; 
      enableAuthorization = true; 
      enableAllFolders = true; 
      enabledFolders = []; 
      adminRoles = [ "jellyfin_admins@${gservices.kanidm.domain}" ]; 
      roles = [ "jellyfin_users@${gservices.kanidm.domain}" ];
      enableFolderRoles = false;
      folderRoleMapping = [];
      roleClaim = "groups"; 
      oidScopes = [ "openid" "profile" "email" "groups" ];
      schemeOverride = "https";
    };
  };
in
{
  imports = [
    ../restic-backup.nix
  ];

  options.glyph.media.jellyfin.enable = mkOption { 
    description = "jellyfin media server"; 
    default = cfg.enable;  
  };

  config = mkIf cfg.jellyfin.enable {
    assertions = [
      {
        assertion = cfg.enable;
        message = "Jellyfin requires nixarr to be enabled";
      }
    ];
    
    nixarr.jellyfin = {
      enable = true;
      stateDir = "/var/lib/jellyfin";
    };

    nixarr.mediaUsers = [ "jellyfin" ];

    glyph.restic.jellyfin.paths = [ "/var/lib/jellyfin" ];

    # secrets
    sops.secrets.jellyfin_api_key = {
      sopsFile = ../../../secrets/sops/jellyfin/secrets.yaml;
      owner = "jellarr";
      key = "api_key";
    };

    age.secrets.kanidm_basic_secret_jellyfin = {
      rekeyFile = ../../../secrets/sources/kanidm/basic_secret_jellyfin.age;
      owner = "jellarr";
      generator.script = "alnum";
    };

    sops.templates."jellar.env".content = ''
      JELLARR_API_KEY="${config.sops.placeholder.jellyfin_api_key}"
    '';
    
    # hardware transcoding support
    users.users.jellyfin.extraGroups = [ 
      "render" 
    ];

    hardware.graphics.enable = true;
    hardware.graphics.extraPackages = with pkgs; [ 
      pkgs.intel-media-driver 
      pkgs.intel-compute-runtime 
      pkgs.vpl-gpu-rt
      pkgs.intel-ocl  
    ];
    hardware.enableAllFirmware = true;
    environment.systemPackages = [ pkgs.jellyfin-ffmpeg ];


    # web ui
    services.nginx.enable = true;

    security.acme.certs.${gservices.jellyfin.public_domain} = {
      reloadServices = [ "nginx.service" ];
      group = "nginx";
    };

    services.nginx.virtualHosts."${gservices.jellyfin.public_domain}" = gservices.nginx.mkReverseProxy {
      proto = "http";
      acme_host = gservices.jellyfin.public_domain;
      domain = gservices.jellyfin.bindaddr;
      port = gservices.jellyfin.bindport;
      listen = [ gservices.headscale.myAddr ];
    };

    glyph.transpose.headscale.dns = [
      (gservices.headscale.mkDnsEntry gservices.jellyfin.host)
    ];

    glyph.transpose.nginx.virtualHosts."${gservices.jellyfin.public_domain}" = gservices.nginx.mkReverseProxy {
      proto = "https";
      domain = "${gservices.headscale.myAddr}";
      port = 443;
    };

    services.jellarr = {
      enable = true;
      environmentFile = config.sops.templates."jellar.env".path;

      bootstrap = {
        enable = true;
        apiKeyFile = config.sops.secrets.jellyfin_api_key.path;
      };

      config = {
        version = 1;
        base_url = "http://${gservices.jellyfin.bindaddr}:${toString gservices.jellyfin.bindport}";
        startup.completeStartupWizard = true;
        system = {
          pluginRepositories = [
            {
              name = "Jellyfin Official";
              url = "https://repo.jellyfin.org/releases/plugin/manifest.json";
              enabled = true;
            }
            {
              name = "Jellyfin-SSO";
              url = "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json ";
              enabled = true;
            }
          ];
          trickplayOptions = {
            enableHwAcceleration = true;
            enableHwEncoding = true;
          };
        };
        encoding = {
          enableHardwareEncoding = true;
          hardwareAccelerationType = "qsv";
          qsvDevice = "/dev/dri/renderD128";
          hardwareDecodingCodecs = [
            "h264"
            "hevc"
            "mpeg2video"
            "vc1"
            "vp8"
            "vp9"
            "av1"
          ];
          enableDecodingColorDepth10Hevc = true;
          enableDecodingColorDepth10HevcRext = true;
          enableDecodingColorDepth12HevcRext =true;
          enableDecodingColorDepth10Vp9 = true;
          allowHevcEncoding = false; # too hard on the server
          allowAv1Encoding = false; # too hard on the client
        };
        branding = {
          loginDisclaimer = ''
            <form action="/sso/OID/start/kanidm">
              <button class="raised block emby-button button-submit">
                Sign In • Anmelden
              </button>
            </form>
          '';
          customCss = ''
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/fixes.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/jf_font.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/base.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/accentlist.css');
            /* skipped: 3 - rounding */
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/smallercast.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/episodelist/episodes_compactlist.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/header/header_transparent.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/login/login_minimalistic.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/fields/fields_border.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/cornerindicator/indicator_floating.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/type/dark_withaccent.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/titlepage/title_banner-logo.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/progress/floating.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/effects/hoverglow.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/effects/glassy.css');
            @import url('https://cdn.jsdelivr.net/gh/CTalvio/Ultrachromic/effects/pan-animation.css');

            .backdropImage {filter: blur(18px) saturate(120%) contrast(120%) brightness(40%);}
            #loginPage::before { 
              background: url(https://i.imgur.com/zOmQOpw.jpeg) !important;
              filter: blur(18px) saturate(120%) contrast(120%) brightness(40%);
            }

            :root {--accent: 180, 73, 0;}
            :root {--rounding: 12px;}

            .manualLoginForm > :not(:first-child) {
              display: none;
              visibility: hidden;
            }

            .btnForgotPassword {
              display: none;
            }

            a.raised.emby-button {
              padding: 0.9em 1em;
              color: inherit !important;
            }

            .disclaimerContainer {
              display: block;
            }
          '';
        };
        library.virtualFolders = [
          {
            name = "Movies • Filme";
            collectionType = "movies";
            libraryOptions.pathInfos = [ {path = "${config.nixarr.mediaDir}/library/movies";} ];
          }
          {
            name = "Shows • Serien";
            collectionType = "tvshows";
            libraryOptions.pathInfos = [ {path = "${config.nixarr.mediaDir}/library/shows";} ];
          }
        ];
        plugins = [
          {
            name = "SSO Authentication";
          }
        ];
      };
    };

    glyph.transpose.kanidm = [{
      age.secrets."kanidm_basic_secret_jellyfin" = {
        rekeyFile = ../../../secrets/sources/kanidm/basic_secret_jellyfin.age;
        owner = "kanidm";
        generator.script = "alnum";
      };
      provision.systems.oauth2."jellyfin" = {
        displayName = "Movies";
        preferShortUsername = true;
        originUrl = "https://${gservices.jellyfin.public_domain}/sso/OID/redirect/kanidm";
        originLanding = "https://${gservices.jellyfin.public_domain}";
        basicSecretFile = nodes."${gservices.kanidm.machine}".config.age.secrets."kanidm_basic_secret_jellyfin".path;
        scopeMaps."jellyfin_users" = [ "openid" "profile" "email" "groups" ];
        imageFile = ../../../assets/jellyfin-logo.svg;
      };
    }];

    systemd.services.jellyfin-configure-sso = {
      after = [ "jellar.service" ];
      wantedBy = [ "jellar.service" ];
      script = ''
        set -euo pipefail
      
        ${lib.toShellVars jellar-post-setup-vars}

        api_key=$(cat ${config.sops.secrets."jellyfin_api_key".path})
        basic_secret=$(cat ${config.age.secrets."kanidm_basic_secret_jellyfin".path})

        echo $SSO_CONFIG | ${lib.getExe pkgs.jq} -c ".oidSecret = \"$basic_secret\"" | ${lib.getExe pkgs.curl} -v \
          -X POST \
          -H "Content-Type: application/json" \
          -H "Authorization: MediaBrowser Token=\"$api_key\"" \
          --data-binary @- \
          "http://${gservices.jellyfin.bindaddr}:${toString gservices.jellyfin.bindport}/sso/OID/Add/kanidm"
      '';
      
      serviceConfig = {
        User = "jellarr";
        Type = "oneshot";
      };
    };
  };
}