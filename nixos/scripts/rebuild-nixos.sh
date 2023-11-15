#!/usr/bin/env bash
# shellcheck disable=SC1091
set -e
set -u

DIR=$(cd "$(dirname "$0")" && pwd)/..
. "$DIR/.env"

type="not-defined"
type="${1}" && shift

force="false"
[ "${1:-}" = "--force" ] && force="true" && shift

host="$1" && shift

if [ "$force" = "true" ]; then
    echo "Rebuild with '$type' system '$host' (default boot entry)."
    nixos-rebuild "$type" --flake "$DIR#$host" --use-remote-sudo
else
    echo "Rebuild with '$type' system '$host' with boot entry name 'test'."
    nixos-rebuild "$type" --flake "$DIR#$host" -p test --use-remote-sudo
fi
