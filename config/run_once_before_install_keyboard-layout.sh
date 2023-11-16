#!/usr/bin/env bash

set -e
set -u

SRC="$CHEZMOI_SOURCE_DIR"

if [ "$CHEZMOI_OS_RELEASE_ID" = "nixos" ]; then
    echo "WARNING: Not going to install keyboard layout in NixOS." >&2
    echo "         Install keyboard in NixOS over the" >&2
    echo "         'https://nixos.org/manual/nixos/stable/#custom-xkb-layouts'." >&2
    exit 0
fi

echo "Installing Qwerty Programmer layout."

if [ "$CHEZMOI_OS" = "linux" ]; then
    "$SRC/keyboard/linux/install.sh"
elif [ "$CHEZMOI_OS" = "darwin" ]; then
    "$SRC/keyboard/macos/install.sh"
else
    echo "Architecture '$CHEZMOI_OS' not supported."
fi
