all@{ config, pkgs, lib, inputs, ... }:
let
  globals = config.globals;
in
{
  imports = [
    ./presets/server.nix
#    ./services/fompf.nix
    ./services/cookbook.nix
    ./services/cartograph.nix
    ./services/nextcloud.nix
    ./services/minecraft.nix
    ./services/kanidm.nix
    ./services/oauth2_proxy.nix
    ./services/headscale.nix
    ./services/tailscale.nix
    ./services/vaultwarden.nix
    ./services/forgejo.nix
#    ./services/syncproxy.nix
#    ./utils/pgsql_update.nix
#    ./tests/oauth2-proxy.nix
  ];
  

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  networking.hostName = "philae";
  networking.interfaces.ens3.useDHCP = true;
  
  nix = {
    settings.trusted-users = [ "root" "@wheel" ];
    nrBuildUsers = 100;
  };

  age.secrets = {
    cloudflare_api.file = ./agenix/cloudflare_secrets.age;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@admin.apophenic.net";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cloudflare_api.path;
    };
    http-challenge-host = "acme.strangegly.ph";
    certs."${globals.domains.base}" = {
      domain = "*.${globals.domains.base}";
      extraDomainNames = [ "*.${globals.services.headscale.net.domain}" ];
      group = "acme";
    };
    certs."acme.strangegly.ph" = {
      extraDomainNames = [ "cookbook.strangegly.ph" ];
    };
  };

  glyph = {
    nextcloud.enable = true;
    kanidm.enable = true;
    headscale.enable = true;
    vaultwarden.enable = true;
    minecraft.enable = true;
    forgejo.enable = true;
  };

  services = {
    cookbook = {
      enable = true;
      vhost = "cookbook.${globals.domains.base}";
      site-name = "Glyph's Cookbook";
      recipe-folder = inputs.cookbook-recipes;
      acme-uses-dns = true;
      acme-host = "${globals.domains.base}";
    };
    nginx.virtualHosts = {
      "cookbook.strangegly.ph" = {
        forceSSL = true;
        useACMEHost = config.security.acme.http-challenge-host;
        globalRedirect = "cookbook.${globals.domains.base}";
      };
    };
    cartograph = {
      enable = true;
      vhost = "wo-ist-ole.strangegly.ph";
      site-name = "Wo Ist Ole?";
    };
    nextcloud = {
      hostName = "cloud.strangegly.ph";
      package = pkgs.nextcloud31;
    };
    postgresql.package = pkgs.postgresql_16;
    tailscale.enable = true;
  };

  users.users = {
    glyph = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRwfYnEBA8Pdsqui9xxLkk7KYpKjA01YvzHx8Sfe1PW lschuetze@aeolus"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFCfbpXsvpFUdCa6QL9PMloDtbTyqvvxLML7o/7w2Pi glyph@rosetta"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUkBx2KFNuQ4K6h7RSxzHNE7Iq/cpiuCD7y97NMq6l2 glyph@pathfinder"
      ];
    };
    fompf = {
      isNormalUser = true;
      shell = pkgs.fish;
    };
    minecraft = {
      isNormalUser = true;
      shell = pkgs.fish;
    };
  };

  home-manager.users.root.imports = [ ../home/philae/root.nix ];
  home-manager.users.glyph.imports = [ ../home/philae/glyph.nix ];
  home-manager.users.minecraft.imports = [ ../home/philae/minecraft.nix ];


  system.stateVersion = "21.05";
}
