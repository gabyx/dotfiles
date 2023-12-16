#!/usr/bin/env bash

# Select the focused window and get its PID and
# change to the PIDs working dir.
focused=$(swaymsg -t get_tree | jq '.. | select(.focused)? | .pid')
cd -P "/proc/$(pgrep -P "$focused" | head -n 1)/cwd" || true

exec "$@"
