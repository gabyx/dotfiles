#!/usr/bin/env bash

set -e
set -u

if [ ! -f ~/.config/chezmoi/key.txt ]; then
    echo "Decrypting chezmoi's decryption/encryption file (age)..."

    mkdir -p ~/.config/chezmoi

    chezmoi age decrypt --output ~/.config/chezmoi/key.txt --passphrase "$CHEZMOI_SOURCE_DIR/dot_config/chezmoi/key.txt.age"

    chmod 600 ~/.config/chezmoi/key.txt
fi
