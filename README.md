# Rough installation instructions

1. Boot NixOS installer and follow instructions up to and including nixos-generate-config
2. `curl https://raw.githubusercontent.com/strangeglyph/nix-home/master/configuration.nix -o /etc/nixos/configuration.nix`
3. `nixos-install`
4. `nixos-enter`, `passwd glyph`
5. Reboot and veryify installation
6. In home `git clone https://github.com/strangeglyph/nix-home.git`
7. `ln -s ~/nix-home ~/.config/nixpkgs`
8. `nix-channel --add https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz home-manager`
9. `nix-channel --update`
10. reboot
11. `nix-shell '<home-manager>' -A install`
12. Done! (May need to log in again)
