# Rough installation instructions

## NixOS config
1. Boot NixOS installer and follow instructions up to but excluding nixos-generate-config
2. `mkdir -p /mnt/etc/nixos`
3. `git clone https://github.com/strangeglyph/nix-home /mnt/etc/nixos/nixos.d`
4. `bash /mnt/etc/nixos/nixos.d/setup-config.sh -r /mnt -h <hostname>`
5. Edit `/mnt/etc/nixos/nixos.d/config/<hostname>.nix` to your liking, if it doesn't exist yet. 
   See e.g. `aeolus.nix` or `euclid.nix`. In particular, set or update `system.stateVersion`.
6. `nixos-install`
7. `nixos-enter`, `passwd <normal user>`
8. Reboot and veryify installation

## HomeManager
1. Log in as the user you want to set up HomeManager for
2. `bash /etc/nixos/nixos.d/setup-home` 
3. Edit `~/nix-home/home/<hostname>/default.nix` and `~/nix-home/home/<hostname>/<user>.nix`, 
   if they don't exist. In particular, set or update `home.stateVersion` in `<user>.nix`.
4. `nix-channel --add https://github.com/nix-community/home-manager/archive/release-<stateVersion>.tar.gz home-manager`
5. `nix-channel --update`
6. reboot
7. `nix-shell '<home-manager>' -A install`
8. Done! (May need to log in again)
