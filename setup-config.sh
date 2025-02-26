
usage() { echo "Usage: $0 -r <system root> -h <hostname> -u <user>" 1>&2; exit 1; }

while getopts ":r:h:" o; do
    case "${o}" in
        r)
            sys_root=${OPTARG}
            ;;
        h)
            new_hostname=${OPTARG}
            ;;
        u)
            default_user=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${sys_root}" ] || [ -z "${new_hostname}" || [ -z "${default_user}" ] ]; then
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

  users.users.${default_user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
    ];
  };
  home-manager.users.root.imports = [ ../home/${new_hostname}/root.nix ];
  home-manager.users.${default_user}.imports = [ ../home/${new_hostname}/${default_user}.nix ];

  # TODO change me
  system.stateVersion = builtins.throw "Please provide a state version";
}
EOF
fi

# Home setup
#

mkdir -p "${sys_root}/etc/nixos/nixos.d/home/${new_hostname}"

if ! [ -f "${sys_root}/etc/nixos/nixos.d/home/${new_hostname}/default.nix" ]; then
    echo "home/${new_hostname}/default.nix does not exist - initializing empty"
    cat > "${sys_root}/etc/nixos/nixos.d/home/${new_hostname}/default.nix <<EOF
{ config, pkgs, lib, ... }:

{
  imports = [ ../default.nix ];
}
EOF
fi

if ! [ -f "${sys_root}/etc/nixos/nixos.d/home/${new_hostname}/root.nix" ]; then
    echo "home/${new_hostname}/root.nix does not exist - initializing empty"
    cat > "${sys_root}/etc/nixos/nixos.d/home/${new_hostname}/root.nix <<EOF
{ config, pkgs, ... }:
{
  imports = [ ./default.nix ];

  home.username = "root";
  home.homeDirectory = "/root";

  # TODO change me
  home.stateVersion = builtins.throw "Please provide a state version";
}
EOF
fi

if ! [ -f "${sys_root}/etc/nixos/nixos.d/home/${new_hostname}/${default_user}.nix" ]; then
    echo "home/${new_hostname}/${default_user}.nix does not exist - initializing empty"
    cat > "${sys_root}/etc/nixos/nixos.d/home/${new_hostname}/${default_user}.nix <<EOF
{ config, pkgs, ... }:
{
  imports = [ ./default.nix ];

  home.username = "${default_user}";
  home.homeDirectory = "/home/${default_user}";

  # TODO change me
  home.stateVersion = builtins.throw "Please provide a state version";
}
EOF
fi



echo "------- [ Done ] -------"
echo "Please customize config/${new_hostname}.nix and home/${new_hostname}/\{${default_user},root\}.nix to your liking"
echo "Please remember to add the home-manager channel and set a state version"
