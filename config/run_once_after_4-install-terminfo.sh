#!/usr/bin/env bash

set -e
set -u

if [ "$CHEZMOI_OS" = "linux" ] || [ "$CHEZMOI_OS" = "darwin" ]; then
    true
else
    echo "Architecture '$CHEZMOI_OS' not supported."
fi

file=~/.config/wezterm/wezterm.terminfo
if [ -f "$file" ] && command -v "tic" &>/dev/null; then
    if [ ! -f ~/.terminfo/w/wezterm ]; then
        tic -x -o ~/.terminfo "$file"
        echo "Installed 'wezterm.terminfo' into '~/.terminfo'."
    fi
else
    echo "WARNING: Cannot install 'wezterm.terminfo':" >&2
    echo "         Either file missing or 'tic' is not installed." >&2
fi
