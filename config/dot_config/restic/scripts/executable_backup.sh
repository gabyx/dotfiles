#!/usr/bin/env bash
# shellcheck disable=SC1090
# TODO: Script will fail if the sudo cache is reset
#       which will again need sudo password.

set -e
set -u

. ~/.config/shell/common/log.sh
. ~/.config/shell/common/platform.sh

. ~/.config/restic/scripts/mount-disks.sh

DISK_PATH=/dev/disk/by-uuid/4877700394137381369

# Flags:
LIST="false"
NONINTERACTIVE="false"
POWEROFF="true"
DATASETS_DEFAULT=(personal work)
DATASETS=()

function parse_args() {
    # Loop through all the arguments
    for arg in "$@"; do
        case $arg in
        --list)
            LIST="true"
            shift
            ;;
        --dataset)
            DATASETS+=("$2")
            shift 2
            ;;
        --no-power-off)
            POWEROFF="false"
            shift
            ;;
        --non-interactive)
            NONINTERACTIVE="true"
            shift
            ;;
        *)
            # Default case for unknown arguments
            echo "Unknown argument: $arg"
            ;;
        esac
    done

    if [ "${#DATASETS[@]}" -eq 0 ]; then
        DATASETS=("${DATASETS_DEFAULT[@]}")
    fi

    gabyx::print_info \
        "NONINTERACTIVE: $NONINTERACTIVE" \
        "DATASETS:\n$(printf ' - %s\n' "${DATASETS[@]}")" \
        "POWEROFF: $POWEROFF"
}

function get_src() {
    local dataset="$1"
    if [ "$dataset" = "personal" ]; then
        echo "/mnt/data/personal"
    elif [ "$dataset" = "work" ]; then
        echo "/mnt/data/work"
    else
        gabyx::die "Dataset '$dataset' not implemented"
    fi
}

function get_dest() {
    local dataset="$1"
    if [ "$dataset" = "personal" ]; then
        echo "/mnt/external-ssd/data-backups/personal"
    elif [ "$dataset" = "work" ]; then
        echo "/mnt/external-ssd/data-backups/work"
    else
        gabyx::die "Dataset '$dataset' not implemented"
    fi
}

function keep_sudo_alive() {
    # Might as well ask for password up-front, right?
    sudo -v

    # Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
    # Explanation:
    # $$ is the PID of the parent process.
    # kill -0 PID exits with an exit code of 0 if the PID is
    # of a running process, otherwise exits with an exit code of 1.
    # So, basically, `kill -0 "$$" || exit`
    # aborts the while loop child process as soon as the
    # parent process is no longer running.
    while true; do
        sudo true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

function restic_backup() {
    local src="$1"
    local dest="$2"

    gabyx::print_info "===============================" \
        "Backing up '$src' to '$dest' with restic."
    (cd "$src" &&
        restic backup -r "$dest" --exclude-file "$general_excludes" ./) ||
        gabyx::die "Backup failed."
    gabyx::print_info "==============================="
}

function backup() {
    echo "Starting backup of all disks..."

    for dataset in "${DATASETS[@]}"; do
        restic_backup \
            "$(get_src "$dataset")" \
            "$(get_dest "$dataset")"

        if [ "$dataset" = "work" ]; then
            # Unmount for sure the encrypted disk.
            unmount zfs-pool-data work
        fi
    done

    list_and_check

    notify "Backup finished."
}

function list_and_check() {
    # export_backup_password
    for dataset in "${DATASETS[@]}"; do
        echo "Snapshots for '$dataset'."
        restic snapshots -r "$(get_dest "$dataset")"

        echo "Checks for '$dataset'."
        restic check -r "$(get_dest "$dataset")"
    done
}

function notify() {
    local what="$1"
    if command -v notify-send &>/dev/null; then
        notify-send --category "$what" "$@" || true
    fi
}

function is_non_interactive() {
    [ "${NONINTERACTIVE}" = "true" ] || return 1
    return 0
}

function prompt_password() {
    if command -v githooks-dialog &>/dev/null; then
        exe="githooks-dialog"
    else
        exe=~"/.githooks/bin/githooks-dialog"
    fi

    "$exe" entry --title "Restic Backup" --text "Enter the password:" --hide-entry
}

function export_backup_password() {
    password_file=~/.config/restic/backup-pass

    if ! is_non_interactive && [ ! -f "$password_file" ]; then
        RESTIC_PASSWORD=$(prompt_password) ||
            gabyx::die "Could not prompt for password."
    else
        RESTIC_PASSWORD=$(cat "$password_file") ||
            gabyx::die "Could not read password file '$password_file'"
    fi

    [ -n "$RESTIC_PASSWORD" ] || gabyx::die "Password is empty."

    export RESTIC_PASSWORD
}

function run_list() {
    export_backup_password

    gabyx::print_info "Import all zfs pools"
    sudo zpool import -f -a

    unmount zfs-pool-external-ssd data-backups || true
    mount zfs-pool-external-ssd data-backups "external-ssd"

    list_and_check
}

function run_backup() {
    notify "Starting restic backup."
    general_excludes=~/.config/restic/general-excludes.txt

    export_backup_password

    gabyx::print_info "Import all zfs pools"
    sudo zpool import -f -a

    # Mount datasets.
    for dataset in "${DATASETS[@]}"; do
        unmount zfs-pool-data "$dataset" || true
        mount zfs-pool-data "$dataset" "data"
    done

    # Mount targets
    unmount zfs-pool-external-ssd data-backups || true
    mount zfs-pool-external-ssd data-backups "external-ssd" || {
        echo "Did you plugin the external-ssd backup disk?" >&2
        exit 1
    }

    backup
}

function unmount_power_off_backup_drive() {
    echo "Unmount backup drive for safety."
    # Export the pool, will unmount everything.
    sudo zpool export zfs-pool-external-ssd

    if [ "$POWEROFF" = "true" ]; then
        echo "Poweroff backup drive for safety."
        # Powerdone external drive.
        sudo udisksctl power-off -b "$DISK_PATH"
    fi
}

function clean_up() {
    unmount_power_off_backup_drive || true
}

function on_error() {
    notify warning "An error occurred in the backup script."
}

trap clean_up EXIT INT
trap on_error ERR

parse_args "$@"

if [ "$LIST" = "true" ]; then
    run_list
else
    keep_sudo_alive
    run_backup
fi
