{ config, pkgs, lib, ... }:

{
  # Use different i3status config for aeolus
  xsession.windowManager.i3.config.bars = lib.mkForce [ 
    {
      fonts = {
        names = [ "FontAwesome" "Source Code Pro" ];
        size = 12.0;
      };
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./dotfiles/i3status-rust.toml}";
    }
  ];
}
