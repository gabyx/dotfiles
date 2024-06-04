#!/usr/bin/env bash

set -e
set -u

function assert_exe() {
    local exe="$1"
    if ! command -v "$exe" &>/dev/null; then
        show_error "Executable '$exe' not found. Did you install it?"
        exit 1
    fi
}

function is_keyring_unlocked() {
    if [ "$CHEZMOI_OS" = "darwin" ]; then
        # We cannot check so we return 0 (unlocked)
        return 0
    elif [ "$CHEZMOI_OS" = "linux" ]; then

        local locked
        locked=$(busctl \
            --user get-property \
            org.freedesktop.secrets \
            /org/freedesktop/secrets/collection/login \
            org.freedesktop.Secret.Collection Locked) || return 1

        if echo "$locked" | grep -q "false"; then
            return 0
        fi
    else
        echo "Keychain unlock test not implemented." >&2
        exit 1
    fi

    return 1
}

function get_password_from_keyring() {
    if command -v secret-tool &>/dev/null; then
        secret-tool lookup chezmoi keyfile-private-key 2>/dev/null
    fi
}

if [ "$CHEZMOI_COMMAND" = "apply" ] &&
    echo "$CHEZMOI_ARGS" | grep -q "exclude encrypted"; then
    # When chezmoi `apply` command is run and encrypted files are excluded
    # we shall not decrypt the keyfile, also making this non-interactive!
    # We need this when configs are installed over NixOS `setup-configs.sh`

    echo "Decrypting chezmoi's encryption key-file (age) NOT necessary!" \
        "We are not applying encrypted files."
    exit 0
fi

if [ ! -f ~/.config/chezmoi/key.txt ]; then
    mkdir -p ~/.config/chezmoi &&
        touch ~/.config/chezmoi/key &&
        chmod 600 ~/.config/chezmoi/key

    echo "Decrypting chezmoi's encryption keyfile (age)..."

    if is_keyring_unlocked; then
        echo "Using keyring to get private-key ..."
        private_key=$(get_password_from_keyring)
    else
        echo -n "Enter encryption private key for 'key.age':"
        read -rs private_key
        echo
    fi

    [ -n "$private_key" ] || {
        echo "Private key for 'key.age' is empty." >&2
        exit 1
    }

    echo "$private_key" | age -i - -d "$CHEZMOI_SOURCE_DIR/dot_config/chezmoi/key.age" \
        >~/.config/chezmoi/key

fi
