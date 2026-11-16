#!/usr/bin/env bash
set -eu
#
# Compute the swap offset for hibernation in `boot.kernelParams`.

ROOT=$(git rev-parse --show-toplevel)
COMP_DIR="$ROOT/components"

host="${1?"not set host"}"

offset=$(sudo btrfs inspect-internal map-swapfile -r /swap/swapfile)
cat >"$COMP_DIR/nix/hosts/${host}/swap-offset.nix" <<EOF
{
  resumeOffset = ${offset};
}
EOF
