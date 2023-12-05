#!/usr/bin/env bash

set -e
set -u

file=~/.config/gnupg/gabyx-private.asc
marker=~/.config/gnupg/.chezmoi-installed

if [ -f "$marker" ]; then
    echo "PGP keys already installed." >&2
    exit 0
fi

if ! command gpg &>/dev/null; then
    echo "WARNING: gnupg is not installed. Cannot install PGP keys." >&2
fi

if [ -f "$file" ]; then
    gpg --import --armor "$file" || {
        echo "WARNING: Import of PGP file '$file' failed." >&2

    }
fi

touch "$marker"
