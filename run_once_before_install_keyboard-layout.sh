#!/usr/bin/env bash

set -e
set -u

SRC="$CHEZMOI_SOURCE_DIR"

echo "Installing Qwerty Programmer layout."

if [ "$CHEZMOI_OS" = "linux" ]; then
    "$SRC/keyboard/linux/install.sh"
elif [ "$CHEZMOI_OS" = "darwin" ]; then
    "$SRC/keyboard/macos/install.sh"
else
    echo "Architecture '$CHEZMOI_OS' not supported."
fi


