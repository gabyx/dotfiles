#!/usr/bin/env bash

set -e
set -u

if [ "$CHEZMOI_OS_RELEASE_ID" = "nixos" ]; then
    exit 0
elif [ -n "${TMUX:-}" ]; then
    echo "WARNING: chezmoi apply inside tmux might interfere with plugin install." >&2
    exit 1
fi
