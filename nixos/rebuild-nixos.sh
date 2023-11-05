#!/usr/bin/env bash
set -e
set -u

DIR=$(cd "$(dirname "$0")" && pwd)
. "$DIR/.env"

type="not-defined"
type="${1}" && shift

force="false"
[ "${1:-}" = "--force" ] && force="true" && shift

config="-vm"
[ -n "${1:-}" ] && config="-$1" && shift

export NIXPGKS_ALLOW_INSECURE=1

if [ "$force" = "true" ]; then
  echo "Rebuild with '$type' system '$config' (default boot entry)."
	sudo nixos-rebuild -I "nixos-config=./configuration$config.nix" \
		"$@" "$type"
else
  echo "Rebuild with '$type' system '$config' with boot entry name 'test'."
	sudo nixos-rebuild -I "nixos-config=./configuration$config.nix" \
		"$@" "$type" -p test
fi
