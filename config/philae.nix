{ config, pkgs, lib, inputs, ... }:

let globals = import ./utils/globals.nix {}; in
{
  imports = [
    ./presets/server.nix
#    ./services/fompf.nix
    ./services/cookbook.nix
    ./services/cartograph.nix
    ./services/nextcloud.nix
    ./services/minecraft.nix
    ./services/kanidm.nix
    ./services/philae/kanidm.nix
    ./services/headscale.nix
    ./services/tailscale.nix
    ./services/vaultwarden.nix
#    ./utils/pgsql_update.nix
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
    kanidm_oauth_interstice = {
      file = ./agenix/kanidm_oauth_interstice.age;
      group = "oauth_interstice";
      mode = "0440";
    };
    vaultwarden_env = {
      file = ./agenix/vaultwarden_env.age;
      #owner = "vaultwarden";
    };
    #tailscale_auth_key.file = ./agenix/tailscale_auth_key_philae.age;
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

  services = {
    cookbook = {
      enable = true;
      vhost = "cookbook.${globals.domains.base}";
      site-name = "Glyph's Cookbook";
      recipe-folder = inputs.cookbook-recipes;
      acme-uses-dns = true;
      acme-host = "${globals.domains.base}";
    };
    nginx.virtualHosts."cookbook.strangegly.ph" = {
      forceSSL = true;
      useACMEHost = config.security.acme.http-challenge-host;
      globalRedirect = "cookbook.${globals.domains.base}";
    };
    cartograph = {
      enable = true;
      vhost = "wo-ist-ole.strangegly.ph";
      site-name = "Wo Ist Ole?";
    };
    nextcloud = {
      enable = true;
      hostName = "cloud.strangegly.ph";
      package = pkgs.nextcloud31;
    };
    postgresql.package = pkgs.postgresql_16;
    kanidm.enable = true;
    headscale.enable = true;
    tailscale.enable = true;
    vaultwarden.enable = true;
    minecraft.enable = false;
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
  users.groups = {
    oauth_interstice.members = [ "headscale" "kanidm" ];
  };
  home-manager.users.root.imports = [ ../home/philae/root.nix ];
  home-manager.users.glyph.imports = [ ../home/philae/glyph.nix ];


  system.stateVersion = "21.05";
}
