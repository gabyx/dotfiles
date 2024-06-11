#!/usr/bin/env bash

# Assigning all workspaces to the correct workspaces.
# Normally Sway does that by it self, but sometimes switching places etc.
# Its better to just run the script.
script=~"/.config/sway/scripts/assign-workspaces-to-outputs.sh"
if [ -f "$script" ]; then
    "$script"
fi

notify-send "Display changed." "Workspace moved to outputs."
