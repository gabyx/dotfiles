#!/usr/bin/env bash
# shellcheck disable=SC1091
set -e
set -u

echo "Generations in 'test' profile:"
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system-profiles/test

echo "Generations in 'system' profile:"
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
