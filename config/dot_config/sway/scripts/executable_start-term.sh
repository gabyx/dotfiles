#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034
set -u

terminal=("$@")

# Launch terminal into tmux.
export RUN_TMUX=true
export RUN_TMUX_SESSION_ID="$1"
shift 1

terminal=("$@")

exec "${terminal[@]}"
