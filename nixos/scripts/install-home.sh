#!/usr/bin/env bash
# shellcheck disable=SC1091
# Setup home (not yet done with home manager)

set -e
set -u

DIR=$(cd "$(dirname "$0")" && pwd)/..
. "$DIR/.env"

# Install dotfiles.
if [ "$DOTFILES_ENABLE" = "true" ]; then
    chezmoi init https://github.com/gabyx/dotfiles.git
    chezmoi apply
fi

# Install my AstroNvim config.
if [ "$NVIM_ASTRO_ENABLE" = "true" ]; then
    [ -d ~/.config/nvim ] || git clone --depth 1 --branch nightly https://github.com/AstroNvim/AstroNvim ~/.config/nvim
    [ -d ~/.config/nvim/lua/user ] || git clone "$NVIM_ASTRO_USER_URL" ~/.config/nvim/lua/user
fi
