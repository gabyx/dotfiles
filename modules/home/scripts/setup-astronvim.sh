#!/usr/bin/env bash
# shellcheck disable=SC1091
# Setup home (not yet done with home manager)

set -e
set -u

if [ -n "${DRY_RUN:-}" ]; then
    echo "Dry-run: No astronvim install."
    exit 0
fi

# Change to home.
cd ~

url="$1"
ref="$2"

function isRepo() {
    git -C "$1" rev-parse --git-dir &>/dev/null
}

if ! isRepo ~/.config/nvim; then
    echo "Clone Astrovim into place."
    git clone --branch "$ref" "$url" ~/.config/nvim
else
    echo "Astrovim already setup"
fi
