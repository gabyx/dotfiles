#!/usr/bin/env bash
#
# This script moves workspaces to the correct monitors.
#
# It detects which primary/secondary setup is used:
#  - `home` or
#  - `work` or
# by inspecting the predefined variables in the `sway` config.
# Otherwise it inspects the default displays `DP-1`, `DP-2` and uses those.
# You can swap the decision by specifying `--swap`.
#
# It then moves all all numbered workspaces `$ws-1, $ws-2, ..., $ws-6` to the
# primary display and moves the rest defined named workspaces `$...-ws`
# to the secondary workspace.
# This script is useful when workspaces get messed up.
# It is also run as a post processing task after `way-displays`.

set -u
set -e
set -o pipefail

function find_defined_monitor_name() {
    local type="$1"
    local which="${2:-primary}"

    local disp_name
    disp_name=$(grep "${which}Disp$type" ~/.config/sway/config | sed -E "s/^set .${which}Disp$type '(.*)'.*/\1/")

    if [ -z "$disp_name" ]; then
        echo "- Display $which '$type' not defined in 'sway/config'." >&2
        return 0
    fi

    swaymsg --pretty -t get_outputs | grep -q "$disp_name" || {
        echo "- Display $which '$disp_name' not found in outputs." >&2
        return 0
    }

    echo "$disp_name"
}

function detect_monitor() {
    local type="$1"
    local -n _disp_name_primary="$2"
    local -n _disp_name_secondary="$3"

    echo "Detecting monitors for type '$type'." >&2

    if echo "$type" | grep -qE "Work|Home"; then
        _disp_name_primary=$(find_defined_monitor_name "$type" primary)
        _disp_name_secondary=$(find_defined_monitor_name "$type" secondary)
    elif echo "$type" | grep -qE "External"; then
        # Detect some external monitors.
        _disp_name_primary=$(swaymsg -t get_outputs --pretty | grep -qE "^Output.* DP-1" | sed -E "s@.*'(.*)'.*@\1@")
        _disp_name_secondary=$(swaymsg -t get_outputs --pretty | grep -qE "^Output.* DP-2" | sed -E "s@.*'(.*)'.*@\1@")
    else
        echo "!! Cannot detect monitors with type '$type'." >&2
        return 1
    fi

    if [ -z "$_disp_name_primary" ]; then
        echo "! No primary monitor for '$type' found."
        return 1
    fi

    if [ -z "$_disp_name_secondary" ]; then
        echo "! No second monitor for '$type' found."
        return 0
    fi

    return 0
}

if [ ! -f ~/.config/sway/config ]; then
    echo "Cannot assign workspaces: '~/.config/sway/config' is missing."
    exit 1
fi

if [ ! -f ~/.config/sway/config-workspaces ]; then
    echo "Cannot assign workspaces: '~/.config/sway/config-workspaces' is missing."
    exit 1
fi

disp_primary=""
disp_secondary=""
do_swap="false"

if [ "${1:-}" = "--swap" ]; then
    do_swap="true"
fi

if detect_monitor "Home" disp_primary disp_secondary; then
    echo "Detected Home monitors." >&2
elif detect_monitor "Work" disp_primary disp_secondary; then
    echo "Detected Work monitors." >&2
elif detect_monitor "External" disp_primary disp_secondary; then
    echo "Detected External monitors." >&2
else
    echo "Detected no monitors to assign workspaces." >&2
    exit 1
fi

if [ -z "$disp_secondary" ]; then
    echo "Secondary monitor not detected, taking primary."
    disp_secondary="$disp_primary"
fi

if [ "$do_swap" = "true" ]; then
    a="$disp_primary"
    disp_primary="$disp_secondary"
    disp_secondary="$a"
    unset a
fi

echo "Settings primary display to: '$disp_primary'."
echo "Settings secondary display to: '$disp_secondary'."

last_focused_ws=$(swaymsg -t get_workspaces -r |
    jq -r ".[] | select(.focused == true) | .name" | sed -E 's/^\d+://')

# Configure all displays.
swaymsg -q "set \$primaryDisp $disp_primary"
swaymsg -q "set \$secondaryDisp '$disp_secondary'"
swaymsg -q "$(sed 's/^#.*//g' ~/.config/sway/config-workspaces)"

# Move existing workspaces to the correct display.
for idx in {1..6}; do
    echo "Move workspace '$idx' to primary display."
    swaymsg -q "workspace \$ws-$idx;
             move workspace to output '$disp_primary'"
done

all_other_workspaces=()
readarray -t all_other_workspaces < <(grep -E '\$\w+-ws' ~/.config/sway/config | sed -E 's/.*(\$\w+-ws).*/\1/g')

for ws in "${all_other_workspaces[@]}"; do
    echo "Move workspace '$ws' to secondary display."
    swaymsg -q "workspace $ws;
         move workspace to output '$disp_secondary'"
done

# Focus last workspace.
swaymsg -q "workspace '$last_focused_ws'"
