{ ... }:
{
  imports = [
    ../services/oauth2_proxy.nix
  ];

  config.glyph.nginx.oauth2-gate."cookbook.apophenic.net" = {
    displayName = "cookbook";
    port = 16924;
  };
}