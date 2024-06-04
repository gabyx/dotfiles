#!/usr/bin/env bash

set -e
set -u

if [ -f ~/.config/chezmoi/key ]; then
    echo "Deleting chezmoi's key-file again."
    rm -rf ~/.config/chezmoi/key
fi
