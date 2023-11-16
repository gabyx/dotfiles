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

if [ ! -d ~/.config/nvim ]; then
    echo "Clone Astrovim into place."
    git clone --branch "$astroVimRef" "$astroVimUrl" ~/.config/nvim/lua/user
else
    echo "Astrovim already setup"
fi

if [ ! -d ~/.config/nvim/lua/user ]; then
    echo "Copy Astrovim User repo into place."
    git clone --branch "$astroVimUserRef" "$astroVimUserUrl" ~/.config/nvim/lua/user
else
    echo "Astrovim User repo already setup."
fi
