#!/usr/bin/env bash
# shellcheck disable=SC1091
# set -e
# set -u

LOG=~/.sway-startup.log

echo "Start" > $LOG

# Save stdout and stderr to file 
exec 3>&1 4>&2 >"$LOG" 2>&1

echo "Starting copyq."
# waybar &
copyq --start-server

# Startup when launching sway.
echo "Starting mail."
swaymsg "workspace '8 Mail'; exec thunderbird;"
sleep 3

echo "Starting web."
swaymsg "workspace '9 Web'; exec firefox;"
sleep 3

echo "Starting comm."
swaymsg "workspace '7 Comm'; exec signal-desktop;"

echo "Waiting"
# Block script
cat

echo "Finished"
