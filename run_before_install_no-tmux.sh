#!/usr/bin/env bash

set -e
set -u

if [ -n "${TMUX:-}" ]; then
    echo "Cannot chezmoi apply inside tmux might interfere with plugin install." >&2
    exit 1
fi
