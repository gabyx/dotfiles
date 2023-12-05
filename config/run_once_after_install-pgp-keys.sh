#!/usr/bin/env bash

set -e
set -u

file=~/.config/gnupg/gabyx-private.asc

if ! command gpg &>/dev/null; then
    echo "WARNING: gnupg is not installed. Cannot install PGP keys." >&2
fi

if [ -f "$file" ]; then
    gpg --import --armor "$file" || {
        echo "WARNING: Import of PGP file '$file' failed." >&2

    }
fi
