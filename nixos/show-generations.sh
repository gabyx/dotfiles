#!/usr/bin/env bash
set -e
set -u

DIR=$(cd "$(dirname "$0")" && pwd)
. "$DIR/.env"

echo "Generations in 'test' profile:"
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system-profiles/test

echo "Generations in 'system' profile:"
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
