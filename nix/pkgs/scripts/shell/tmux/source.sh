#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_TMUX:-}" != "loaded" ]; then

    # Restore `tmux` with the `$1`-th last saved settings.
    # After this function invoke a `Tmux-Leader + Ctrl+R`
    # to trigger resurrect.
    function gabyx::tmux_resurrect_restore() {
        local dir=~/.local/share/tmux/resurrect
        local last_index="$1"

        fd "tmux_.*" "$dir" --change-older-than 1weeks --exec rm || {
            gabyx::print_error "Could not clean up"
        }

        local last_file
        gabyx::find_recent "$dir" "tmux_.*" | cut -d ' ' -f 3- | tail "-$last_index"
        last_file=$(gabyx::find_recent "$dir" "tmux_.*" | cut -d ' ' -f 3- | tail "-$last_index" | head -1)

        if [ ! -f "$last_file" ]; then
            gabyx::print_info "No last file in '$dir'"
        fi

        gabyx::print_info "Last file '$last_file' contains:"
        cat "$last_file"

        gabyx::print_info "Restore last file."
        rm "$dir/last" || true
        ln -s "$last_file" "$dir/last" || {
            gabyx::print_error "Could not symlink last file."
        }
    }

    # Creates a new tmux sessions with name `$1`
    # and root directory `$2` and session layout `$3`
    # and window layout `$4`.
    # If it already exist it will load the window layout `$3`.
    # If `--force` is given the already existing session
    # is closed and reopened.
    function gabyx::tmux_new_session() {
        local force="false"

        [ "$1" != "--force" ] || {
            shift 1
            force="true"
        }

        if [ -n "$TMUX" ]; then
            gabyx::print_error "Detach first from this session and run the command again."
            return 1
        fi

        local name="${1:-default}"
        local root="${2:-$(pwd)}"
        local session_layout="${3:-default}"
        local window_layout="${4:-default}"

        if tmux list-sessions -F "#{session_name}" | grep -q "$name"; then
            if [ "$force" = "true" ]; then
                gabyx::print_info "Closing session '$name'."
                tmux kill-session -t "$name"
            else
                gabyx::print_warning "Session with '$name' already exists." \
                    "Use 'tmuxfier load-window $window_layout'." \
                    "or use '--force' to close it and reload it."
            fi
        fi

        gabyx::print_info "Creating session '$name'."

        TMUXIFIER_ROOT_DIR="$root" \
            TMUXIFIER_SESSION_NAME="$name" \
            TMUXIFIER_WINDOW_LAYOUT="$window_layout" \
            tmuxifier load-session "$session_layout"
    }

    export GABYX_LIB_TMUX="loaded"
fi
