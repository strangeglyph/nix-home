
usage() { echo "Usage: $0 [-u <user>]" 1>&2; exit 1; }
homedir() {
    local result; result="$(getent passwd "$1")" || (echo "User $1 does not exist"; exit 1)
    echo "$result" | cut -d : -f 6
}

while getopts ":u:" o; do
    case "${o}" in
        u)
            user=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${user}" ] ; then
    user="$(whoami)"
fi

home="$(homedir $user)"
nixpkgs="$home/.config/nixpkgs"
nixhome_file="$nixpkgs/home.nix"
nixhome_dir="$nixpkgs/nix-home.d"

mkdir -p "$nixpkgs"

if ! [ -d "${nixhome_dir}" ]; then
    echo "Unable to find extended configuration directory nix-home.d in ${nixpkgs}"
    echo "Where did you get this script from?"
    echo "Would you like to initialize nix-home.d from https://github.com/strangeglyph/nix-home now?"
    read -p "y/N> " answer
    if [ "${answer}" = "y" ]; then
        git clone https://github.com/strangeglyph/nix-home "${nixhome_dir}" || (echo "Initialization failed"; exit 1)
    else
        echo "Please initialize nix-home.d manually"
        exit 1
    fi
fi

if [ -f "${nixhome_file}" ] ; then
    echo "Backing up ${nixhome_file} to ${nixhome_file}.old"
    mv "${nixhome_file}" "${nixhome_file}.old"
fi

echo "Writing new configuration.nix"
cat > "${nixhome_file}" <<EOF
# This file has been auto-generated. Please modify the default
# in ./nix-home.d/home/default.nix or the host specific configuration
# in ./nix-home.d/home/$(hostname)/default.nix or the user specific configuration
# in ./nix-home.d/home/$(hostname)/${user}.nix

{ config, pkgs, ... }:

{
  imports =
    [
      ./nix-home.d/home/default.nix
      ./nix-home.d/home/$(hostname)/default.nix
      ./nix-home.d/home/$(hostname)/${user}.nix
    ];
}
EOF

mkdir -p "${nixhome_dir}/home/$(hostname)"

if ! [ -f "${nixhome_dir}/home/$(hostname)/default.nix" ]; then
    echo "$(hostname)/default.nix does not exist - initializing empty"
    cat > "${nixhome_dir}/home/$(hostname)/default.nix" <<EOF
{ config, pkgs, ... }:

{
}
EOF
fi

if ! [ -f "${nixhome_dir}/home/$(hostname)/${user}.nix" ]; then
    echo "$(hostname)/${user}.nix does not exist - initializing defaults"
    cat > "${nixhome_dir}/home/$(hostname)/${user}.nix" <<EOF
{ config, pkgs, ... }:

{
    home.username = "${user}";
    home.homeDirectory = "${home}";
}
EOF
fi

if ! [ -d "$home/nix-home" ]; then
  ln -s "$nixhome_dir" "$home/nix-home"
fi
