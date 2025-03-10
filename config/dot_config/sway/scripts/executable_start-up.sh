#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034,SC1090,SC2016
# set -e
# set -u

LOG=~/.sway-startup.log

function start_tmux() {
    # Start tmux and make sessions.
    echo "Start tmux, let it recreate the workspaces with resurrect"

    tmuxEnv=~/.config/tmux/.tmux-env
    if [ ! -f "$tmuxEnv" ]; then
        echo "Cannot start tmux because the '~/.config/tmux/.tmux-env' " >&2
        echo "file is not here to source 'TMUX_TMPDIR'." >&2
        exit 1
    fi

    source "$tmuxEnv"

    [ -n "$TMUX_TMPDIR" ] || {
        echo "Env. TMUX_TMPDIR is not set!" >&2
        exit 1
    }
    echo "TMUX_TMPDIR: '$TMUX_TMPDIR'"

    # Start the server and make sure it uses the correct TERM= variable.
    tmux start-server
    tmux display-message -p 'Tmux: socket path: #{socket_path}'
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
    swaymsg 'workspace $ws-2; exec $term-start AstroNVim $term-start-cmd'
    swaymsg 'workspace $ws-3; exec $term-start Main-1 $term-start-cmd'
    swaymsg 'workspace $ws-4; exec $term-start Main-2 $term-start-cmd'
    swaymsg 'workspace $ws-1; exec $term-start NixOS $term-start-cmd'
}

function start_display_manager() {
    echo "Start 'way-displays -g' to reassign the workspaces if needed."
    echo "Somehow 'way-displays' crashed on start-up sometimes and this helps."
    # See: https://github.com/alex-courtis/way-displays/issues/171
    sleep 1
    swaymsg exec '$display-manager -g'
}

function start_davmail() {
    echo "Start davmail to sync calendar items."

    local dir=~/.local/state/davmail/secrets

    mkdir -p "$dir" && chmod 700 "$dir"
    if [ ! -f "$dir/token" ]; then
        touch "$dir/token" && chmod 600 "$dir/token"
    fi

    swaymsg exec davmail ~/.config/davmail/properties
}
function start_clipboard() {
    echo "Start clipboard."
    swaymsg exec \$clipboard
}

# Save stdout and stderr to file
exec 3>&1 4>&2 >"$LOG" 2>&1

echo "============"
sleep 0.5

start_clipboard
start_davmail

# Seems to be fixed.
# display_manager

if true; then
    notify-send "Using wezterm: not starting tmux" || true
else
    tmux
fi

echo "Finished"
