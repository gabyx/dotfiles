#!/usr/bin/env bash

# Select the focused window and get its PID and
# change to the PIDs working dir.
focused=$(swaymsg -t get_tree | jq '.. | select(.focused)? | .pid') || {
    echo "No focused window to get cwd from." >&2
}

cwd="/proc/$(pgrep -P "$focused" | head -n 1)/cwd" || {
    echo "No parent process found for '$focused'" >&2
}

if [ -d "$cwd" ]; then
    cd -P "$cwd" || true
fi

exec "$@"
