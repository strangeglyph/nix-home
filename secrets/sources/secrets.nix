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
  # cf api key
  "cloudflare_secrets.age".publicKeys = all;
  # headscale oauth client secret
  "kanidm_oauth_interstice.age".publicKeys = all;
  # oauth2-proxy oauth client secret
  "kanidm_oauth_portcullis.age".publicKeys = all;
  
  # other oauth2-proxy settings
  "oauth2-proxy.age".publicKeys = all;
  # vaultwarden settings
  "vaultwarden_env.age".publicKeys = all;
  
  # RPTU VPN config for aeolus
  "wg-rptu-split-aeolus.age".publicKeys = aeolus;
}
