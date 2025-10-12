# Rough installation instructions

## Configuration
1. In flake.nix -> `colmenaHive`: Add an entry for the target machine
2. Add `config/<hostname>.nix`, `hw/<hostname>.nix` (or auto-generate with `nixos-anywhere`, see below), probably a `disko` config
3. Home manager, if necessary
4. Secrets, if necessary

## Installation
1. Make sure the target machine has ssh open, and register an ssh key with root
2. Test the configuration: `nixos-anywhere -- --flake .#<hostname> --vm-test`
3. Install nixos, `nixos-anywhere -- --flake .#<hostname> --generate-hardware-config nixos-generate-config ./hw/<hostname>.nix --target-host root@<host-ip>` ( !! host-ip, not hostname, as hostname lookup may be lost )
4. SSH into the machine, run `tailscale up --login-server=<globals.headscale_domain>`
5. Future install/update with `colmena apply --on <hostname>`
