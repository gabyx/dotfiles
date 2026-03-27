# Start into tmux session directly on startup.
# Set env. variable `RUN_TMUX=true` and `RUN_TMUX_SESSION_ID=???`.
if [ "${RUN_TMUX:-}" = "true" ] &&
    [ -x "$(command -v tmux 2>/dev/null)" ] &&
    [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then

    RUN_TMUX_SESSION_ID="${RUN_TMUX_SESSION_ID:-Main}"
    echo "Entering tmux session '$RUN_TMUX_SESSION_ID' from '.zshrc' "

    # Unset this variable as soon as its consumed.
    unset RUN_TMUX


    if [ -z "$TMUX_TMPDIR" ]; then
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
    fi

    echo "TMUX_TMPDIR: '$TMUX_TMPDIR'"
    tmux display-message -p 'Tmux: socket path: #{socket_path}'

    tmux new-session -A -s "$RUN_TMUX_SESSION_ID" >/dev/null 2>&1

    echo "Leaving tmux session."
fi
