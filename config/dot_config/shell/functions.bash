#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091

eval "$(gabyx::shell-source)" || {
    echo "Could not 'eval \$(gabyx::source)'."
} >&2

function gabyx::compress_pdf() {
    local file="$1"
    local output="$2"
    local level="${3:-screen}"

    if [[ ! $level =~ (screen|ebook|prepress|default) ]]; then
        gabyx::print_error "The level must be something of 'screen|ebook|prepress|default'." >&2
        return 1
    fi

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        "-dPDFSETTINGS=/$level" \
        -dNOPAUSE \
        -dBATCH \
        "-sOutputFile=$output" "$file"
}

# Login into the Bitwarden CLI
# and make the session variable `BW_SESSION` available.
function gabyx::bitwarden() {
    BW_SESSION=$(bw login gnuetzi@gmail.com --raw)
    export BW_SESSION
}

# Connect the NordVPN connection.
function gabyx::nordvpn_connect() {
    wgnord-up "$@"
}

# Disconnect the NordVPN connection.
function gabyx::nordvpn_disconnect() {
    wgnord-down "$@"
}

# Connect to the named VPN connection.
function gabyx::vpn_connect() {
    local name="${1:-ETH Zurich}"
    nmcli connection up "$1" --ask
}

function gabyx::get_k3s_killall_script() {
    local temp
    temp=$(mktemp)

    curl -sL https://raw.githubusercontent.com/smartin77/create-k3s-killall/main/create-k3s-killall.sh -o "$temp"
    if [ "$(sha256sum "$temp" | cut -d ' ' -f 1)" != "b93e95218beb47cf37ca4313e61d0fab26514aa168e8aea610a21a04f5780a8e" ]; then
        gabyx::print_error "SHA sum of script does not match!" >&2
        return 1
    fi
    cd ~/.config/kube || return 1

    gabyx::print_info "Writing 'k3s-killall.sh' to '~/.config/kube'"
    bash "$temp"

    rm -f "$temp"
}

# Kill all `k3s` (kubernetes) instances.
function gabyx::k3s_killall() {
    if [ ! -f ~/.config/kube/k3s-killall.sh ]; then
        gabyx::get_k3s_killall_script
    fi

    ~/.config/kube/k3s-killall.sh
}

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

# Print the keycodes of the active keyboard.
function gabyx::print_keycode_table {
    xmodmap -pke
}

# Get a keycode from a keypress.
function gabyx::get_keycode {
    xev
}

# Get the window tree in JSON format in `sway`.
function gabyx::get_window_properties {
    swaymsg -t get_tree | jq
}

# Get information on the input device from `sway`.
function gabyx::get_input_properties {
    local device_type="${1:-touchpad}"
    swaymsg -t get_inputs --raw | jq ".[] | select(.type==\"$device_type\")"
}

# Get the last boot log.
function gabyx::nixos_last_boot_log() {
    journalctl -b -1 -e
}

# Get the whole log for all user systemd services.
function gabyx::nixos_systemd_log() {
    journalctl --user -e
}

# Get the log of the systemd service with name `$1`.
# User log is: `user@1000`.
function gabyx::nixos_systemd_log_for() {
    local service="$1"
    journalctl -u "$service.service" -e
}

# Get the log of the home-manager systemd service.
function gabyx::nixos_hm_log() {
    journalctl -u home-manager-nixos.service -e
}

# List all running kernel modules.
function gabyx::nixos_kernel_modules() {
    lsmod
}

# Rebuild the system with Nix.
function gabyx::nixos_rebuild() {
    local what="${1:?Specify how? 'switch,boot,test'}"
    shift 1
    local host="${1:?Specify a host to build}"
    shift 1

    if command -v just &>/dev/null; then
        (
            cd "$(readlink ~/nixos-config)" &&
                just rebuild "$what" "$host"

            if [[ $what =~ switch\|test ]]; then
                gabyx::print_info "Differences are:"
                just diff 1
            elif [[ $what =~ build ]]; then
                gabyx::print_info "Differences are:"
                just diff /run/current-system result
            fi
        )
    else
        (cd "$(readlink ~/nixos-config)" &&
            nixos-rebuild "$what" --flake ".#$host" --use-remote-sudo "$@")
    fi
}

# Activate a python environment under Nix.
function gabyx::nixos_activate_python_env() {
    local env="${1:-default}"
    local dir="$HOME/python-envs"

    if [ -d "$dir/.$env" ] || [ ! -d "$dir/$env" ]; then
        rm -rf "$dir/.$env" || true

        (cd ~/.local/share/chezmoi/home/python-envs &&
            nix build ".#python-envs.$env" -o "$dir/.$env" &&
            "$dir/.$env/bin/python" -m venv --system-site-packages "$dir/$env") ||
            {
                gabyx::print_error "Failed to create the python environment '$dir/$env'." >&2
                return 1
            }
    fi

    # shellcheck disable=SC1090
    source "$dir/$env/bin/activate"
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
