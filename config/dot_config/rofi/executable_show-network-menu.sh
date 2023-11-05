#!/usr/bin/env bash

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

"$DIR/scripts/nmcli-rofi.sh"
