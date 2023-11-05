#!/usr/bin/env bash
# shellcheck disable=SC1091
set -e
set -u

DIR=$(cd "$(dirname "$0")" && pwd)/..
. "$DIR/.env"

echo "Generations in 'test' profile:"
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system-profiles/test

echo "Generations in 'system' profile:"
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
