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

function assert_exe() {
    local exe="$1"
    if ! command -v "$exe" &>/dev/null; then
        show_error "Executable '$exe' not found. Did you install it?"
        exit 1
    fi
}

function is_keyring_locked() {
    local locked
    locked=$(busctl \
        --user get-property \
        org.freedesktop.secrets \
        /org/freedesktop/secrets/collection/login \
        org.freedesktop.Secret.Collection Locked) || return 1

    [ "$locked" = "true" ] || return 1
    return 0
}

function get_password_from_keyring() {
    if command -v secret-tool &>/dev/null; then
        secret-tool lookup chezmoi keyfile-passphrase 2>/dev/null
    fi
}

if [ ! -f ~/.config/chezmoi/key.txt ]; then
    mkdir -p ~/.config/chezmoi &&
        touch ~/.config/chezmoi/key &&
        chmod 600 ~/.config/chezmoi/key

    echo "Decrypting chezmoi's encryption keyfile (age)..."
    if ! is_keyring_locked && password=$(get_password_from_keyring) && [ -n "$password" ]; then
        echo "Using keyring to decrypt ..."
        AGE_PASSPHRASE="$password" \
            age -d "$CHEZMOI_SOURCE_DIR/dot_config/chezmoi/key.age" 2>/dev/null \
            >~/.config/chezmoi/key
    else
        echo "Keyring is locked or no entry with 'attribute: chezmoi', key: 'keyfile-passphrase'."
        echo "Using 'chezmoi age decrypt' to prompt"
        chezmoi age decrypt \
            --output ~/.config/chezmoi/key \
            --passphrase "$CHEZMOI_SOURCE_DIR/dot_config/chezmoi/key.age"
    fi
fi
