# Rough installation instructions

1. Make sure the target machine has ssh open, and register an ssh key with root
2. In flake.nix -> `colmenaHive`: Add an entry for the target machine
3. Add `config/<hostname>.nix`, `hw/<hostname>.nix`
4. Home manager, if necessary
5. Secrets, if necessary
6. Install with `colmena apply --on <hostname>`
