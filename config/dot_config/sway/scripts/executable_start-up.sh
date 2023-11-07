#!/usr/bin/env bash
# shellcheck disable=SC1091
# set -e
# set -u

LOG=~/.sway-startup.log

echo "Start" > $LOG

# Save stdout and stderr to file 
exec 3>&1 4>&2 >"$LOG" 2>&1

# Place here special things.
sleep 1
swaymsg exec \$clipboard

swaymsg "workspace 1; exec \$term tmux;"

echo "Finished"
