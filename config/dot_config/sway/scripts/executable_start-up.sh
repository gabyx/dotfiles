#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034,SC1090
# set -e
# set -u

LOG=~/.sway-startup.log

# Save stdout and stderr to file
exec 3>&1 4>&2 >"$LOG" 2>&1

sleep 0.5
# Start the clipboard manager.
echo "Start clipboard."
swaymsg exec \$clipboard

# Start tmux and make sessions.
echo "Start tmux, let it recreate the workspaces with resurrect"

tmuxEnv=~/.config/tmux/.tmux-env
if [ ! -f "$tmuxEnv" ]; then
    echo "Cannot start tmux because the '~/.config/tmux/.tmux-env' " >&2
    echo "file is not here to source 'TMUX_TMPDIR'." >&2
    exit 1
fi
source "$tmuxEnv"

tmux start-server
echo "Server started."
sleep 4

tmux list-sessions || {
    echo "ERROR: The exit-empty is not set to off, so the server directly exits!" >&2
}

# Create all sessions if not yet existing
tmux new-session -D -s Main-1
tmux new-session -D -s Main-2
tmux new-session -D -s AstroNVim
tmux new-session -D -s NixOS

echo "Sessions are:"
tmux list-sessions || {
    echo "ERROR: Sessions should now be available!" >&2
}
echo "-----------"

echo "Start workspaces"
swaymsg "workspace \$ws-1; exec \$term-start NixOS \$term-start-cmd"
swaymsg "workspace \$ws-2; exec \$term-start AstroNVim \$term-start-cmd"
swaymsg "workspace \$ws-3; exec \$term-start Main-1 \$term-start-cmd"
swaymsg "workspace \$ws-4; exec \$term-start Main-2 \$term-start-cmd"

echo "Finished"
