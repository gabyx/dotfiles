#!/usr/bin/env bash

set -e
set -u

file=~/.config/gnupg/gabyx-private.asc

echo "Install PGP key: '$file' ..."
if ! command -v gpg &>/dev/null; then
    echo "WARNING: gnupg is not installed. Cannot install PGP keys." >&2
fi

if [ -f "$file" ]; then
    printf "PGP Password: "
    read -sr password </dev/tty

    gpg --import --passphrase-file <(echo "$password") --pinentry-mode loopback --armor "$file" || {
        echo "WARNING: Import of PGP file '$file' failed." >&2
        exit 1
    }
fi
