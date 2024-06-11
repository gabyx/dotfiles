#!/usr/bin/env bash
#
# This script moves workspaces to the correct monitors.
# It detects which primary/secondary setup is used: either `home` or `work` setup
# by inspecting the predefined variables in the `sway` config.
# It then moves all all numbered workspaces `$ws-1, $ws-2, ..., $ws-6` to the
# primary display and moves the rest defined named workspaces `$...-ws`
# to the secondary workspace.
# This script is useful when workspaces get messed up.
# It is also run as a post processing task after `way-displays`.

set -u
set -e
set -o pipefail

function get_primary_monitor_name() {
    local type="$1"
    local disp_name
    disp_name=$(grep "primaryDisp$type" ~/.config/sway/config | sed -E "s/^set .primaryDisp$type '(.*)'.*/\1/")

    echo "$disp_name"
}

function get_secondary_monitor_name() {
    local type="$1"
    local disp_name
    disp_name=$(grep "secondaryDisp$type" ~/.config/sway/config | sed -E "s/^set .secondaryDisp$type '(.*)'.*/\1/")

    echo "$disp_name"
}

function is_at_home() {
    local disp_name
    disp_name=$(get_primary_monitor_name Home)

    if [ -z "$disp_name" ]; then
        echo "Primary home display not defined in 'sway/config'." >&2
        return 1
    fi

    swaymsg --pretty -t get_outputs | grep -q "$disp_name" || return 1
    return 0
}

function is_at_work() {
    local disp_name
    disp_name=$(get_primary_monitor_name Work)

    if [ -z "$disp_name" ]; then
        echo "Primary work display not defined in 'sway/config'." >&2
        return 1
    fi

    swaymsg --pretty -t get_outputs | grep -q "$disp_name" || return 1
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

if is_at_home; then
    primaryDisp=$(get_primary_monitor_name Home)
    secondaryDisp=$(get_secondary_monitor_name Home)
elif is_at_work; then
    primaryDisp=$(get_primary_monitor_name Work)
    secondaryDisp=$(get_secondary_monitor_name Work)
else
    echo "Displays not detected." >&2
    exit 1
fi

if [ -z "$secondaryDisp" ]; then
    echo ""
    secondaryDisp="$primaryDisp"
fi

echo "Settings primary display to: '$primaryDisp'."
echo "Settings secondary display to: '$secondaryDisp'."

last_focused_ws=$(swaymsg -t get_workspaces -r |
    jq -r ".[] | select(.focused == true) | .name" | sed -E 's/^\d+://')

# Configure all displays.
swaymsg "set \$primaryDisp '$primaryDisp'"
swaymsg "set \$secondaryDisp '$secondaryDisp'"
swaymsg "$(sed 's/^#.*//g' ~/.config/sway/config-workspaces)"

# Move existing workspaces to the correct display.
for idx in {1..6}; do
    echo "Move workspace '$idx' to primary display."
    swaymsg "workspace \$ws-$idx;
             move workspace to output '$primaryDisp'"
done

all_other_workspaces=()
readarray -t all_other_workspaces < <(grep -E '\$\w+-ws' ~/.config/sway/config | sed -E 's/.*(\$\w+-ws).*/\1/g')

for ws in "${all_other_workspaces[@]}"; do
    echo "Move workspace '$ws' to secondary display."
    swaymsg "workspace $ws;
         move workspace to output '$secondaryDisp'"
done

# Focus last workspace.
swaymsg "workspace '$last_focused_ws'"
