#!/usr/bin/env bash
# shellcheck disable=SC1091
set -e
set -u

ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/nixos/.env-os-vm"

if [ -f "$NIXOS_DISK" ]; then
    echo "Disk '$NIXOS_DISK' already existing! Delete it if you want to reinstall NixOS." >&2
else
    qemu-img create -f qcow2 "$NIXOS_DISK" "$NIXOS_DISK_SIZE"
fi

"$DIR/start-vm.sh" \
    -boot d \
    -cdrom "$NIXOS_ISO"
