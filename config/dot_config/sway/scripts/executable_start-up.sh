#!/usr/bin/env bash
# shellcheck disable=SC1091
# set -e
# set -u

LOG=~/.sway-startup.log

echo "Start" > $LOG

# Save stdout and stderr to file 
exec 3>&1 4>&2 >"$LOG" 2>&1

sleep 1
# Start the clipboard manager.
swaymsg exec \$clipboard

# Start tmux and make terminal on workspace 1.
tmux start-server
sleep 1
swaymsg "workspace 1; exec \$term tmux a"

echo "Finished"
