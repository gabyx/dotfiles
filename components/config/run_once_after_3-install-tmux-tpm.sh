#!/usr/bin/env bash

set -e
set -u

if [ "$CHEZMOI_OS_RELEASE_ID" = "nixos" ]; then
    exit 0
elif [ -n "${TMUX:-}" ]; then
    echo "WARNING: chezmoi apply inside tmux might interfere with plugin install." >&2
    echo "         Not going to install tmux plugins." >&2
    exit 1
fi

if [ "$CHEZMOI_OS_RELEASE_ID" = "nixos" ]; then
    echo "WARNING: Tmux plugins are not going to be installed in NixOS." >&2
    echo "         They are installed in NixOS configuration." >&2
    exit 0
fi

if [ "$CHEZMOI_OS" = "linux" ] || [ "$CHEZMOI_OS" = "darwin" ]; then
    true
else
    echo "Architecture '$CHEZMOI_OS' not supported."
fi

~/.config/tmux/scripts/install-tpm.sh
~/.config/tmux/scripts/install-tpm-plugins.sh
