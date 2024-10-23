#!/usr/bin/env bash
# shellcheck disable=SC2015
# =========================================================================================
# Chezmoi Setup
#
# @date 17.3.2023
# @author Gabriel Nützi, gnuetzi@gmail.com
# =========================================================================================
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
if [ ! -f "$SCRIPT_DIR" ]; then
    SCRIPT_DIR="$HOME/.config/shell"
fi

. "$SCRIPT_DIR/common/log.sh" || {
    echo "Could not source 'log.sh'."
} >&2

# Mount all ZFS disks.
function gabyx::mount_zfs_disks() {
    ~/.config/shell/mount-zfs-disks.sh "$@"
}

# Unmount all ZFS disks.
function gabyx::unmount_zfs_disks() {
    ~/.config/shell/mount-zfs-disks.sh --unmount "$@"
}

# Find recent files in the dir `$1`.
function gabyx::find_recent() {
    local dir="$1"
    shift 1

    fd "$@" "$dir" --exec find {} -printf "%T@ %Td-%Tb-%TY %TT %p\n" |
        sort -n | cut -d " " -f 2-
}

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
    local region="${1:-ch}"
    # Create some folders such that wgnord does not have troubles.
    #
    sudo mkdir -p /etc/wireguard
    sudo mkdir -p /var/lib/wgnord

    sudo chmod -R 600 /etc/wireguard/

    if [ -f /etx/wireguard/wgnord.conf ]; then
        sudo chmod o=-r,-w /etc/wireguard/wgnord.conf
    fi

    sudo curl -sL --output "/var/lib/wgnord/template.conf" \
        "https://raw.githubusercontent.com/phirecc/wgnord/a5ffc4ddb87de23d4165d13bf4d8dc1e06a49fbd/template.conf"

    sudo wgnord connect "$region"
}

# Disconnect the NordVPN connection.
function gabyx::nordvpn_disconnect() {
    sudo wgnord disconnect
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

# Remove `docker` or `podman` images with a regex `$1`.
# Use `--use-podman` as first argument if
# you want `podman` instead of `docker`.
function gabyx::remove_docker_images() {
    local builder="docker"

    if [ "$1" = "--use-podman" ]; then
        shift 1
        builder="podman"
    fi

    [ -z "$1" ] && {
        gabyx::print_error "Empty regex given."
        return 1
    }
    images=$("$builder" images --format '{{.ID}}|{{.Repository}}:{{.Tag}}' | grep -v '<none>' |
        grep -xE "(\w+)\|$1" | sed -E "s/(\w+)\|.*/\1/g")
    [ -z "$images" ] && {
        gabyx::print_warning "No images found."
        return 0
    }

    gabyx::print_info "Deleting images:"
    echo "$images"
    echo "$images" | xargs -n 1 "$builder" rmi --force
}

function gabyx::copy_images_to_podman() {
    transport="docker-daemon"

    [ -z "$1" ] && {
        gabyx::print_error "Empty regex given."
        return 1
    }

    gabyx::print_info "Copying images with regex '$1' from docker to podman."
    images=$(docker images --format "$transport:{{.Repository}}:{{.Tag}}" | grep -v 'wnonew' | grep -xE "$transport:$1")

    echo "$images" | xargs printf "  - '%s'\n"
    echo "$images" | xargs podman pull
}

# Call my file regex/replace script.
function gabyx::file_regex_replace() {
    "$HOME/.config/shell/file-regex-replace.py" "$@"
}

# Print the keycodes of the active keyboard.
function gabyx::gabyx::print_keycode_table {
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
function gabyx::nixos_systemd_log() {
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

# Run the backup script.
function gabyx::backup_zfs() {
    ~/.config/restic/scripts/backup.sh
}

# List all backups.
function gabyx::list_backups() {
    ~/.config/restic/scripts/backup.sh --list
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

# Deletes branches which have not received any commit for a '$1' weeks (default 8).
# Will only delete if there is no branch on the remote with the same name
function gabyx::delete_branches_older_than_weeks() {
    local force="false"
    local remote="true"
    local older_than_weeks="8"

    while [ "$#" -gt 0 ]; do
        case "$1" in
        -f | --force)
            force="true"
            shift
            ;;
        --no-remote)
            remote="false"
            shift
            ;;
        --weeks)
            older_than_weeks="$2"
            shift 2
            ;;
        *)
            # Default case for unknown arguments
            gabyx::print_error "Unknown argument: $1"
            return 1
            ;;
        esac
    done

    if ! [[ $older_than_weeks =~ ^[0-9]+$ ]]; then
        gabyx::print_error "Input needs to be a number."
        return 1
    fi

    gabyx::print_info "Remove all tracking branches no more on remote."
    git fetch -p
    git remote prune origin

    local remote_branches
    remote_branches=$(git ls-remote origin "refs/heads/*" 2>/dev/null | sed -E s@refs/heads/@@g) || {
        gabyx::print_error "Could not get remote branches."
        return 1
    }

    branches=()
    local msg="Would delete"
    if [ "$force" = "true" ]; then
        msg="Delete"
    fi

    gabyx::print_info "Searching for branches with no commit for '$older_than_weeks' weeks."

    for k in $(git branch | sed /\*/d); do
        if [ -z "$(git log -1 --since="$older_than_weeks week ago" -s "$k")" ]; then
            # Contains a commit!
            continue
        fi

        if [[ $remote == "false" ]]; then
            gabyx::print_info "$msg branch '$k'."
            branches+=("$k")
        elif ! echo "$remote_branches" | grep -q "$k"; then
            gabyx::print_info "Branch '$k' does not exist anymore on remote."
            gabyx::print_info "$msg branch '$k'."
            branches+=("$k")
        fi
    done

    for k in "${branches[@]}"; do
        if [ "$force" = "true" ]; then
            git branch -D "$k"
        fi
    done
}
