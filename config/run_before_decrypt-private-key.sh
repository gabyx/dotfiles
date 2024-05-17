#!/usr/bin/env bash

set -e
set -u

if [ "$CHEZMOI_COMMAND" = "apply" ] &&
    echo "$CHEZMOI_ARGS" | grep -q "exclude encrypted"; then
    # When chezmoi `appply` command is run and encrypted files are excluded
    # we shall not decrypt the keyfile, also making this non-interactive!
    # We need this when configs are installed over NixOS `setup-configs.sh`

    echo "Decrypting chezmoi's encryption key-file (age) NOT necessary!" \
        "We are not applying encrypted files."
    exit 0
fi

if [ ! -f ~/.config/chezmoi/key.txt ]; then
    # This will ask for the password to store the age
    # encryption key.
    echo "Decrypting chezmoi's encryption keyfile (age)..."

    mkdir -p ~/.config/chezmoi

    chezmoi age decrypt \
        --output ~/.config/chezmoi/key.txt \
        --passphrase "$CHEZMOI_SOURCE_DIR/dot_config/chezmoi/key.txt.age"

    chmod 600 ~/.config/chezmoi/key.txt
fi
