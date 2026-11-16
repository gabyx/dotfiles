#!/bin/usr/env bash
#
# Pass these environment variables to start a new default session.
export TMUXIFIER_ROOT_DIR="${TMUXIFIER_ROOT_DIR:-$HOME}"
export TMUXIFIER_SESSION_NAME="${TMUXIFIER_SESSION_NAME:-default}"
export TMUXIFIER_WINDOW_LAYOUT="${TMUXIFIER_WINDOW_LAYOUT:-default}"

# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.

session_root "$TMUXIFIER_ROOT_DIR"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "$TMUXIFIER_SESSION_NAME"; then

    # Create a new window inline within session layout definition.
    # new_window "Main"

    # Load a defined window layout.
    load_window "default"

    # Select the default active window on session creation.
    select_window 1

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
