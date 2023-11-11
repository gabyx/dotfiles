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
echo "Start tmux, let it recreate the workspaces with resurrect"
tmux start-server
echo "Server started."

tmux new-session -d -A -s Main

echo "Sessions are:"
tmux list-sessions || {
    echo "The exit-empty is not set to off, so the server directly exits!" >&2
}
echo "-----------"

tmux send-keys -t Main "$HOME/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh" Enter
sleep 3
echo "Sent resurrect command."

echo "Start workspaces"
swaymsg "workspace \$ws-1; exec \$term-start Dotfiles \$term-start-cmd"
swaymsg "workspace \$ws-2; exec \$term-start Astrovim \$term-start-cmd"
swaymsg "workspace \$ws-3; exec \$term-start Main \$term-start-cmd"
swaymsg "workspace \$ws-4; exec \$term-start Main \$term-start-cmd"
echo "Finished"
