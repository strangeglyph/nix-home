let
  root-philae = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMwEfAnpup4jYH0fU9bNV7ZkzVFqKr8kdmUuFjRdZTwM";
  philae = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINiKxbjXxheaT3gXvzY6KHtR/V5akJQLVwOFN+aU08u5";
in
{
  "cloudflare_secrets.age".publicKeys = [ root-philae philae ];
  "kanidm_oauth_interstice.age".publicKeys = [ root-philae philae ];
}
