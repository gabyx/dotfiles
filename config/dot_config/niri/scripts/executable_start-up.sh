#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034,SC1090,SC2016
# set -e
# set -u

LOG=~/.niri-startup.log

function start_davmail() {
    echo "Start davmail to sync calendar items."

    local dir=~/.local/state/davmail/secrets

    mkdir -p "$dir" && chmod 700 "$dir"
    if [ ! -f "$dir/token" ]; then
        touch "$dir/token" && chmod 600 "$dir/token"
    fi

    niri msg action spawn -- davmail ~/.config/davmail/properties
}

# Save stdout and stderr to file
exec 3>&1 4>&2 >"$LOG" 2>&1

echo "============"
sleep 0.5

start_davmail

if true; then
    notify-send "Using wezterm: not starting tmux" || true
else
    tmux
fi

echo "Finished"
