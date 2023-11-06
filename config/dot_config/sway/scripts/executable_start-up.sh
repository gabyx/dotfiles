#!/usr/bin/env bash
# shellcheck disable=SC1091
# set -e
# set -u

LOG=~/.sway-startup.log

echo "Start" > $LOG

# Save stdout and stderr to file 
exec 3>&1 4>&2 >"$LOG" 2>&1

sleep 1
echo "Starting copyq."
swaymsg "exec \$clipboard"

# Startup when launching sway.
echo "Starting mail."
swaymsg "workspace \$mail-ws; exec \$mail" 
sleep 2

echo "Starting web."
swaymsg "workspace \$web-ws; exec \$web" 
sleep 2

echo "Starting comm."
swaymsg "workspace \$comm-ws; exec \$comm" 

echo "Finished"
