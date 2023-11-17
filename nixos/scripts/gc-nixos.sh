#!/usr/bin/env bash
# shellcheck disable=SC1091
set -e
set -u

ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/nixos/.env"

# Reduce the test generations down to one.
sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system-profiles/test +1

# Run garbage collection, but not deleting generations `-d`
sudo nix-collect-garbage
