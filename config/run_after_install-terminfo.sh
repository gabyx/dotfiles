#!/usr/bin/env bash

set -e
set -u

if [ "$CHEZMOI_OS_RELEASE_ID" = "nixos" ]; then
    echo "WARNING: Terminfo addtionals is not going to be installed in NixOS." >&2
    echo "         They are installed in NixOS configuration." >&2
    exit 0
fi

if [ "$CHEZMOI_OS" = "linux" ] || [ "$CHEZMOI_OS" = "darwin" ]; then
    true
else
    echo "Architecture '$CHEZMOI_OS' not supported."
fi

terminfo=~"/.config/wezterm/wezterm.terminfo"
if [ -f "$terminfo" ] && command -v "tic" &>/dev/null; then
    tic -x -o ~/.terminfo "$terminfo"
    echo "Installed 'wezterm.terminfo' into '~/.terminfo'."
else
    echo "WARNING: Cannot install 'wezterm.terminfo':" >&2
    echo "         Either file missing or 'tic' is not installed." >&2
fi
