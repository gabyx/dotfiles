#!/usr/bin/env bash
set -eu
#
# Compute the swap offset for hibernation in `boot.kernelParams`.

ROOT=$(git rev-parse --show-toplevel)

host="${1?"not set host"}"

offset=$(sudo btrfs inspect-internal map-swapfile -r /swap/swapfile)
cat >"$ROOT/nixos/hosts/${host}/swap-offset.nix" <<EOF
{
  resumeOffset = ${offset};
}
EOF
