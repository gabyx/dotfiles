#!/usr/bin/env bash

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if [ "$1" = "--wireless" ]; then
    "$DIR/scripts/nmcli-rofi.sh"
elif [ "$1" = "--editor" ]; then
    nm-connection-editor
else
    echo "No command given." >2
fi
