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

astroVimUrl="$1"
astroVimRef="$2"

astroVimUserUrl="$3"
astroVimUserRef="$4"

function isRepo() {
    git -C "$1" rev-parse --git-dir &>/dev/null
}

if ! isRepo ~/.config/nvim; then
    echo "Clone Astrovim into place."
    git clone --branch "$astroVimRef" "$astroVimUrl" ~/.config/nvim
else
    echo "Astrovim already setup"
fi

if  ! isRepo ~/.config/nvim/lua/user ; then
    echo "Copy Astrovim User repo into place."
    git clone --branch "$astroVimUserRef" "$astroVimUserUrl" ~/.config/nvim/lua/user
else
    echo "Astrovim User repo already setup."
fi
