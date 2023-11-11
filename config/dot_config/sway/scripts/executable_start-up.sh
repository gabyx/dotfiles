#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034
# set -e
# set -u

LOG=~/.sway-startup.log

# Save stdout and stderr to file
exec 3>&1 4>&2 >"$LOG" 2>&1

sleep 0.5
# Start the clipboard manager.
echo "Start clipboard."
swaymsg exec \$clipboard

# Start tmux and make terminal on workspace 1.
echo "Start tmux."
swaymsg exec tmux
sleep 1

echo "Start workspaces"

export RUN_TMUX_SESSION="Dotfiles"
swaymsg "workspace \$ws-1; exec \$term"
sleep 0.5

export RUN_TMUX_SESSION="Astrovim"
swaymsg "workspace \$ws-2; exec \$term"
sleep 0.5

export RUN_TMUX_SESSION="Main"
swaymsg "workspace \$ws-3; exec \$term"
sleep 0.5

export RUN_TMUX_SESSION="Main"
swaymsg "workspace \$ws-4; exec \$term"

echo "Finished"
