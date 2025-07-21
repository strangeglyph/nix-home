let
  root-philae = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMwEfAnpup4jYH0fU9bNV7ZkzVFqKr8kdmUuFjRdZTwM";
  system-philae = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINiKxbjXxheaT3gXvzY6KHtR/V5akJQLVwOFN+aU08u5";

  lschuetze-aeolus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRwfYnEBA8Pdsqui9xxLkk7KYpKjA01YvzHx8Sfe1PW";
  system-aeolus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0V//PYSFB4kQAUeaWLvD8j/VPtd5KqymkifABOw12g";
  
  editors = [ lschuetze-aeolus ];
  aeolus = [ lschuetze-aeolus system-aeolus ];
  philae = [ root-philae system-philae ];
  all = philae ++ aeolus;
in
{
  "cloudflare_secrets.age".publicKeys = all;
  "kanidm_oauth_interstice.age".publicKeys = all;
  "vaultwarden_env.age".publicKeys = all;
  "wg-rptu-split-aeolus.age".publicKeys = aeolus;
}
