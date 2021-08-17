
usage() { echo "Usage: $0 -r <system root> -h <hostname>" 1>&2; exit 1; }

while getopts ":r:h:" o; do
    case "${o}" in
        r)
            sys_root=${OPTARG}
            ;;
        h)
            new_hostname=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${sys_root}" ] || [ -z "${new_hostname}" ]; then
    usage
fi

if ! [ -d "${sys_root}/etc/nixos/nixos.d" ]; then
    echo "Unable to find extended configuration directory nixos.d in ${sys_root}/etc/nixos/"
    echo "Where did you get this script from?"
    echo "Would you like to initialize nixos.d from https://github.com/strangeglyph/nix-home now?"
    read -p "y/N> " answer
    if [ "${answer}" = "y" ]; then
        git clone https://github.com/strangeglyph/nix-home "${sys_root}/etc/nixos/nixos.d" || (echo "Initialization failed"; exit 1)
    else
        echo "Please initialize nixos.d manually"
        exit 1
    fi
fi

echo "Generating nixos config in ${sys_root}"
nixos-generate-config --root "${sys_root}"

echo "Backing up ${sys_root}/etc/nixos/configuration.nix to ${sys_root}/etc/nixos/configuration.nix.old"
mv "${sys_root}/etc/nixos/configuration.nix" "${sys_root}/etc/nixos/configuration.nix.old"

echo "Writing new configuration.nix"
cat > "${sys_root}/etc/nixos/configuration.nix" <<EOF
# This file has been auto-generated. Please modify the default
# in ./nixos.d/config/default.nix or the host specific configuration
# in ./nixos.d/config/${new_hostname}.nix

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./nixos.d/config/default.nix
      ./nixos.d/config/${new_hostname}.nix
    ];
}
EOF

if ! [ -f "${sys_root}/etc/nixos/nixos.d/config/${new_hostname}.nix" ]; then
    echo "${new_hostname}.nix does not exist - initializing empty"
    cat > "${sys_root}/etc/nixos/nixos.d/config/${new_hostname}.nix" <<EOF
{ config, pkgs, ... }:

{
  networking.hostname = "${new_hostname}";
}
EOF
    echo "Please customize this file to your liking"
fi
