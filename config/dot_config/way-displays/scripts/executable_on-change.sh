#!/usr/bin/env bash
# Assigning all workspaces to the correct workspaces.
# Normally Sway does that by it self, but sometimes switching places etc.
# Its better to just run the script.
set -u
set -e

script="$HOME/.config/sway/scripts/assign-workspaces-to-outputs.sh"
if [ -f "$script" ]; then
    # shellcheck disable=SC2015
    out=$("$script" 2>&1) &&
        # echo -e "OnChanged:: Workspace moved\n$out" >>~/.way-displays.log ||
        # echo -e "OnChanged:: Workspace not moved\n$out" >>~/.way-displays.log
        notify-send "Display changed." "$(echo -e "Workspace moved:\n$out")" ||
        notify-send -u critical "Display changed." "$(echo -e "Workspace not moved:\n$out")"
fi
