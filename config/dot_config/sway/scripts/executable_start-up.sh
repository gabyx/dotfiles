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
sleep 3

tmux list-sessions || {
  echo "ERROR: The exit-empty is not set to off, so the server directly exits!" >&2
}

# Create all sessions if not yet existing
tmux new-session -D -s Main
tmux new-session -D -s Astrovim
tmux new-session -D -s Dotfiles

echo "Sessions are:"
tmux list-sessions || {
  echo "ERROR: Sessions should now be available!" >&2
}
echo "-----------"

# tmux send-keys -t Main "$HOME/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh" Enter
# echo "Sent resurrect command."
#
# sleep 10
# # tmux send-keys -t Main.0 nvim Enter
# # tmux send-keys -t Astrovim.0 nvim Enter
# # tmux send-keys -t Dotfiles.0 nvim Enter
# # echo "Started nvim in all sessions"
#
echo "Start workspaces"
swaymsg "workspace \$ws-1; exec \$term-start Dotfiles \$term-start-cmd"
swaymsg "workspace \$ws-2; exec \$term-start Astrovim \$term-start-cmd"
swaymsg "workspace \$ws-3; exec \$term-start Main \$term-start-cmd"
swaymsg "workspace \$ws-4; exec \$term-start Main \$term-start-cmd"

echo "Finished"
