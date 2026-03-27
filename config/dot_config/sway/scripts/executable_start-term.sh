#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034
set -u

terminal=("$@")

# Launch terminal into tmux if first argument is given.
if [ -n "${1:-}" ]; then
    export RUN_TMUX=true
    export RUN_TMUX_SESSION_ID="$1"
fi
shift 1

terminal=("$@")

exec "${terminal[@]}"
