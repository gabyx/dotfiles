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

if [ ! -d ~/.config/nvim ]; then
    echo "Clone Astrovim into place."
    git clone --depth 1 --branch stable \
        "https://github.com/AstroNvim/AstroNvim" \
        ~/.config/nvim
else
    echo "Astrovim already setup"
fi

if [ -d ~/.config/nvim/lua/user ]; then
    echo "Clone Astrovim User repo into place."
    git clone "https://github.com/gabyx/astrovim.git" \
        ~/.config/nvim/lua/user
else
    echo "Astrovim User repo already setup."
fi
