#!/usr/bin/env bash

set -e
set -u

echo "Installing tmux tpm plugins."
tmux start-server &&
    tmux new-session -d &&
    sleep 1 &&
    ~/.config/tmux/plugins/tpm/scripts/install_plugins.sh &&
    tmux kill-server
