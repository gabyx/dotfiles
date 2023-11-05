#!/usr/bin/env bash
set -e
set -u

DIR=$(cd "$(dirname "$0")" && pwd)
. "$DIR/.env"

# Reduce the test generations down to one.
sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system-profiles/test +1

# Run garbage collection, but not deleting generations `-d`
sudo nix-collect-garbage
