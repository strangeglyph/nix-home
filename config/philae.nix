{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  globals = config.globals;
in
{
  imports = [
    ./fragments
    ./services
    #    ./utils/pgsql_update.nix
    #    ./tests/oauth2-proxy.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  glyph = {
    users.glyph.privileged = true;

    nginx-public.enable = true;
    nextcloud.enable = true;
    kanidm.enable = true;
    headscale.enable = true;
    vaultwarden.enable = true;
    minecraft.enable = false;
    forgejo.enable = true;
    paperless.enable = true;
    actualbudget.enable = true;
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
    cartograph = {
      enable = true;
      vhost = "wo-ist-ole.${globals.domains.base}";
      site-name = "Wo Ist Ole?";
    };
    nextcloud = {
      hostName = "cloud.${globals.domains.base}";
      package = pkgs.nextcloud32;
    };
    postgresql.package = pkgs.postgresql_16;
  };
}
