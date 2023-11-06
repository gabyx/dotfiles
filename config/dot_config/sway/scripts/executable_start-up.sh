#!/usr/bin/env bash
# shellcheck disable=SC1091
# set -e
# set -u

LOG=~/.sway-startup.log

echo "Start" > $LOG

# Save stdout and stderr to file 
exec 3>&1 4>&2 >"$LOG" 2>&1

sleep 1
# echo "Starting copyq."
# swaymsg "\$clipboard"

# Startup when launching sway.
echo "Starting mail."
swaymsg "\$mail" 
sleep 2

echo "Starting web."
swaymsg "\$web" 
sleep 2

echo "Starting comm."
swaymsg "\$comm" 

echo "Finished"
