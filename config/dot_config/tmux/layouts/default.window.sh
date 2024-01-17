#!/bin/usr/env bash
#
# Pass these environment variables to start a new default session.
TMUXIFIER_ROOT_DIR="${TMUXIFIER_ROOT_DIR:-$HOME}"

# Set window root path. Default is `$session_root`.
# Must be called before `new_window`.
window_root "$TMUXIFIER_ROOT_DIR"

# Create new window. If no argument is given, window name will be based on
# layout file name.
new_window "default"
split_h 30
split_v 50
run_cmd "nvim" 0 # runs in pane 0

new_window "auxiliary"

# Set active pane.
select_pane 0
select_window 1
