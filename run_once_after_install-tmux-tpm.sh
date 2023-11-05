#!/usr/bin/env bash

set -e
set -u

if [ "$CHEZMOI_OS" = "linux" ] || [ "$CHEZMOI_OS" = "darwin" ]; then
    true
else
    echo "Architecture '$CHEZMOI_OS' not supported."
fi

~/.config/tmux/scripts/install-tpm.sh
~/.config/tmux/scripts/install-tpm-plugins.sh
