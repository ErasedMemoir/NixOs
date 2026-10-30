#!/usr/bin/env bash
#
# Install from the NixOS live ISO. Run as root from a root-owned clone.
#
#   ./install.sh facter  <host>          write hosts/<host>/facter.json
#   ./install.sh format  <host> <disk>   erase <disk>, partition it, mount it on /mnt
#   ./install.sh mount   <host> <disk>   mount an already formatted <disk> on /mnt
#   ./install.sh install <host>          copy the repo, set the password, install
set -euo pipefail

readonly USER_NAME="erased"
readonly USER_UID=1000
readonly USER_GID=100 # users

nix() {
  command nix --extra-experimental-features "nix-command flakes" "$@"
}

die() {
  printf '\e[31mERROR: %s\e[0m\n' "$*" >&2
  exit 1
}

info() {
  printf '\e[32m==> %s\e[0m\n' "$*"
}

usage() {
  sed -n '3,8p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

require_root() {
  [[ $(id -u) -eq 0 ]] || die "this script must be run as root"
}

require_host() {
  [[ -n ${1:-} ]] || die "host not specified"
  [[ -f hosts/$1/default.nix ]] || die "hosts/$1/default.nix does not exist"
}

require_disk() {
  [[ -n ${1:-} ]] || die "install disk not specified"
  [[ -b $1 ]] || die "install disk '$1' is not a block device"
}

require_mounted() {
  mountpoint -q /mnt || die "/mnt is not mounted; run 'format' or 'mount' first"
}

# disko.nix uses /dev/diskoTarget as the device.
select_disk() {
  ln -sf "$1" /dev/diskoTarget
}

disko() {
  nix run --inputs-from . disko -- --flake ".#$1" --mode "$2"
}

cmd_facter() {
  local report="hosts/$1/facter.json"
  info "Detecting hardware into $report"
  nix run --inputs-from . nixpkgs#nixos-facter -- -o "$report"
  chmod 644 "$report"
  # Flakes only see files tracked by git.
  git add "$report"
}

cmd_format() {
  info "Formatting $2 for host $1 (all data on it will be destroyed)"
  select_disk "$2"
  disko "$1" destroy,format,mount
}

cmd_mount() {
  info "Mounting $2 for host $1"
  select_disk "$2"
  disko "$1" mount
}

cmd_install() {
  local secrets=/mnt/data/secrets

  info "Copying the configuration to /mnt/data/etc/nixos"
  mkdir -p /mnt/data/etc/nixos
  cp -a ./. /mnt/data/etc/nixos/
  chown -R "$USER_UID:$USER_GID" /mnt/data/etc/nixos

  info "Choose the password for $USER_NAME"
  install -d -m 700 "$secrets"
  (
    umask 077
    nix run --inputs-from . nixpkgs#mkpasswd -- -m yescrypt >"$secrets/$USER_NAME.hash"
  )
  [[ -s $secrets/$USER_NAME.hash ]] || die "password hash was not written"

  info "Installing NixOS for host $1"
  nixos-install --no-root-passwd --no-channel-copy --flake ".#$1"

  # The bootloader creates the Secure Boot keys on the root subvolume, which
  # is wiped at boot; keep them on /data.
  if [[ -d /mnt/var/lib/sbctl ]]; then
    install -d -m 700 /mnt/data/var/lib/sbctl
    cp -a /mnt/var/lib/sbctl/. /mnt/data/var/lib/sbctl/
  fi

  info "Done. Reboot and remove the USB stick."
}

main() {
  [[ -f flake.nix ]] || die "run this script from the repository root"

  case "${1:-}" in
    facter)
      require_root
      require_host "${2:-}"
      cmd_facter "$2"
      ;;
    format | mount)
      require_root
      require_host "${2:-}"
      require_disk "${3:-}"
      "cmd_$1" "$2" "$3"
      ;;
    install)
      require_root
      require_host "${2:-}"
      require_mounted
      cmd_install "$2"
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
