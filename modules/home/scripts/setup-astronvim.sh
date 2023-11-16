#!/usr/bin/env bash
# shellcheck disable=SC1091
# Setup home (not yet done with home manager)

set -e
set -u

if [ -n "${DRY_RUN:-}" ]; then
    echo "Dry-run: No nvim install."
    exit 0
fi

# Change to home.
cd ~

astroVimStore="$1"
astroVimURL="$2"

astroVimUserStore="$3"
astroVimUserURL="$4"

if [ ! -d ~/.config/nvim ]; then
    echo "Copy Astrovim into place from store '$astroVimStore'."
    cp -r "$astroVimStore" ~/.config/nvim
    git -C ~/.config/nvim remote set-url origin "${astroVimURL}"
else
    echo "Astrovim already setup"
fi

if [ -d ~/.config/nvim/lua/user ]; then
    echo "Copy Astrovim User repo into place from store '$astroVimUserStore'."
    cp -r "$astroVimUserStore" ~/.config/nvim/lua/user
    git -C ~/.config/nvim/lua/user remote set-url origin "${astroVimUserURL}"
else
    echo "Astrovim User repo already setup."
fi
