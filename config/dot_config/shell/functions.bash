#!/usr/bin/env bash
# shellcheck disable=SC2015
# =========================================================================================
# Chezmoi Setup
#
# @date 17.3.2023
# @author Gabriel Nützi, gnuetzi@gmail.com
# =========================================================================================
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
. "$SCRIPT_DIR/common/log.sh"

function gabyx::mount_zfs_disks() {
    ~/.config/shell/mount-zfs-disks.sh "$@"
}

function gabyx::unmount_zfs_disks() {
    ~/.config/shell/mount-zfs-disks.sh --unmount "$@"
}

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

    if [[ ! "$level" =~ (screen|ebook|prepress|default) ]]; then
        gabyx::print_error "The level must be something of 'screen|ebook|prepress|default'." >&2
        return 1
    fi

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        "-dPDFSETTINGS=/$level" \
        -dNOPAUSE \
        -dBATCH \
        "-sOutputFile=$output" "$file"
}

function gabyx::bitwarden() {
    BW_SESSION=$(bw login gnuetzi@gmail.com --raw)
    export BW_SESSION
}

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

function gabyx::nordvpn_disconnect() {
    sudo wgnord disconnect
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

function gabyx::k3s_killall() {
    if [ ! -f ~/.config/kube/k3s-killall.sh ]; then
        gabyx::get_k3s_killall_script
    fi

    ~/.config/kube/k3s-killall.sh
}

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
    echo "$images" | xargs -n 1 docker rmi --force
}

function gabyx::copy_images_to_podman() {
    transport="docker-daemon"

    [ -z "$1" ] && {
        gabyx::print_error "Empty regex given."
        return 1
    }

    gabyx::print_info "Copying images with regex '$1' from docker to podman."
    images=$(docker images --format "$transport:{{.Repository}}:{{.Tag}}" | grep -v '<none>' | grep -xE "$transport:$1")

    echo "$images" | xargs printf "  - '%s'\n"
    echo "$images" | xargs podman pull
}

function gabyx::file_regex_replace() {
    "$HOME/.config/shell/file-regex-replace.py" "$@"
}

function gabyx::gabyx::print_keycode_table {
    xmodmap -pke
}

function gabyx::get_keycode {
    xev
}

function gabyx::get_window_properties {
    swaymsg -t get_tree | jq
}

function gabyx::nixos_systemd_log() {
    local service="$1"
    journalctl -u "$service.service" -e
}

function gabyx::nixos_hm_log() {
    journalctl -u home-manager-nixos.service -e
}

function gabyx::backup_zfs() {
    ~/.config/restic/backup.sh
}

function gabyx::nixos_rebuild() {
    local what="${1:?Specify how? 'switch,boot,test'}"
    shift 1
    local host="${1:?Specify a host to build}"
    shift 1

    if command -v just &>/dev/null; then
        (
            cd "$(readlink ~/nixos-config)" &&
                just rebuild "$what" "$host"

            if [[ "$what" =~ switch\|test ]]; then
                gabyx::print_info "Differences are:"
                just diff 1
            elif [[ "$what" =~ build ]]; then
                gabyx::print_info "Differences are:"
                just diff /run/current-system result
            fi
        )
    else
        (cd "$(readlink ~/nixos-config)" &&
            nixos-rebuild "$what" --flake ".#$host" --use-remote-sudo "$@")
    fi
}

function gabyx::nixos_activate_python_env() {
    local env="$1"
    local dir="$HOME/python-envs"

    if [ -d "$dir/.$env" ] || [ ! -d "$dir/$env" ]; then
        rm -rf "$dir/.$env" || true

        (cd ~/nixos-config/home/python-envs &&
            nix build ".#python-envs.$env" -o "$dir/.$env" &&
            "$dir/.$env/bin/python" -m venv --system-site-packages "$dir/$env") ||
            {
                gabyx::print_error "Failed to activate environment '$env'." >&2
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
