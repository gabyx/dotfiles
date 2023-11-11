#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034
# set -e
# set -u

LOG=~/.sway-startup.log

# Save stdout and stderr to file
exec 3>&1 4>&2 >"$LOG" 2>&1

sleep 0.5
# Start the clipboard manager.
echo "Start clipboard."
swaymsg exec \$clipboard

# Start tmux and make terminal on workspace 1.
echo "Start tmux, let it recreate the workspaces with resurrec (?)"
swaymsg exec tmux
sleep 2

echo "Start workspaces"
swaymsg "workspace \$ws-1; exec \$term-start Dotfiles \$term-start-cmd"
swaymsg "workspace \$ws-2; exec \$term-start Astrovim \$term-start-cmd"
swaymsg "workspace \$ws-3; exec \$term-start Main \$term-start-cmd"
swaymsg "workspace \$ws-4; exec \$term-start Main \$term-start-cmd"

echo "Finished"
