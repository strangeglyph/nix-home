{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    email = "admin@strangegly.ph";
  };

  services = {
    openssh = {
      enable = true;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRwfYnEBA8Pdsqui9xxLkk7KYpKjA01YvzHx8Sfe1PW lschuetze@aeolus"
  ];
}
