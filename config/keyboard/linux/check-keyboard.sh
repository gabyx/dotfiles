#!/usr/bin/env bash

set -u
set -e

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
. "$DIR/../../common/log.sh"

setxkbmap "-I$DIR/symbols" programmer -print |
    xkbcomp "-I$DIR" - "$DISPLAY" ||
    die "The layout '$DIR/symbols/programmer' is invalid." \
    "Check with:" \
        "setxkbmap \"-I$DIR/symbols\" programmer -print \|" \
        "xkbcomp \"-I$DIR/symbols\" - \"$DISPLAY\""
