#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153
#
# Backup all ZFS disks.

set -e
set -u

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
. "$SCRIPT_DIR/../common/source.sh"
. "$SCRIPT_DIR/zfs.sh"

DISK_PATH=/dev/disk/by-uuid/4877700394137381369
BACKUP_VOLUME_MOUNTED="false"
PASSWORD_FILE_ROOT=/run/secrets/restic/backup-pass
PASSWORD_FILE_USER=~/.config/restic/backup-pass
RESTIC_PASSWORD_FILE=""

# User/group permissions.
USER_UID=1000
USER_GID=$(id "$USER_UID" -g)
CHOWN_TO_USER="false"

# Flags:
LIST="false"
NONINTERACTIVE="false"
POWEROFF="true"
DATASETS_DEFAULT=(personal work)
DATASETS=()

function parse_args() {
    # Loop through all the arguments
    while [[ $# -gt 0 ]]; do
        local arg="$1"
        case "$arg" in
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
        --chwon-to-user)
            CHOWN_TO_USER="true"
            shift
            ;;
        --non-interactive)
            NONINTERACTIVE="true"
            shift
            ;;
        *)
            # Default case for unknown arguments
            gabyx::die "Unknown argument: $arg"
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

# The location to backup.
function get_src() {
    local dataset="$1"

    case "$dataset" in
    personal)
        echo "/mnt/data/personal"
        ;;
    work)
        echo "/mnt/data/work"
        ;;
    *)
        gabyx::die "Dataset '$dataset' not implemented"
        ;;
    esac
}

# The location to backup to.
function get_dest() {
    local dataset="$1"

    case "$dataset" in
    personal)
        echo "/mnt/external-ssd/data-backups/personal"
        ;;
    work)
        echo "/mnt/external-ssd/data-backups/work"
        ;;
    *)
        gabyx::die "Dataset '$dataset' not implemented"
        ;;
    esac
}

function keep_sudo_alive() {
    # Might as well ask for password up-front, right?
    gabyx::sudo -v

    # Keep-alive: update existing gabyx::sudo time stamp if set, otherwise do nothing.
    # Explanation:
    # $$ is the PID of this script's process.
    # kill -0 PID exits with an exit code of 0 if the PID is
    # of a running process, otherwise exits with an exit code of 1.
    # So, basically, `kill -0 "$$" || exit`
    # aborts the while loop child process as soon as the
    # parent process is no longer running.
    while true; do
        gabyx::sudo true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

function restic_backup() {
    local src="$1"
    local dest="$2"

    gabyx::print_info "===============================" \
        "Backing up '$src' to '$dest' with restic."

    [ -d "$src" ] || gabyx::die "Src: '$src' does not exist."
    [ -d "$dest" ] || gabyx::die "Dest: '$dest' does not exist."

    # Run restic as the user who
    gabyx::sudo restic backup \
        --password-file "$RESTIC_PASSWORD_FILE" \
        -r "$dest" \
        --exclude-file "$general_excludes" "$src/" ||
        gabyx::die "Backup failed."

    if [ "$CHOWN_TO_USER" = "true" ]; then
        gabyx::print_info "Chown everything to '$USER_UID:$USER_GID'"
        gabyx::sudo chown -R "$USER_UID:$USER_GID" "$dest"
    fi

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
            gabyx::unmount_zfs zfs-pool-data work
        fi
    done

    list_and_check

    notify "Backup finished."
}

function list_and_check() {
    # export_backup_password
    for dataset in "${DATASETS[@]}"; do
        echo "Snapshots for '$dataset'."
        gabyx::sudo restic --password-file "$RESTIC_PASSWORD_FILE" snapshots -r "$(get_dest "$dataset")"

        echo "Checks for '$dataset'."
        gabyx::sudo restic --password-file "$RESTIC_PASSWORD_FILE" check -r "$(get_dest "$dataset")"
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

function set_password_file() {
    if gabyx::is_root; then

        if ! [[ -e $PASSWORD_FILE_ROOT && -r $PASSWORD_FILE_ROOT ]]; then
            gabyx::die "Could not read password file '$PASSWORD_FILE_ROOT'"
        fi
        gabyx::print_info "Using passfile '$PASSWORD_FILE_ROOT'."
        RESTIC_PASSWORD_FILE="$PASSWORD_FILE_ROOT"

    elif gabyx::is_user "$USER_UID"; then

        if [[ -e $PASSWORD_FILE_USER && -r $PASSWORD_FILE_USER ]]; then
            gabyx::print_info "Using passfile '$PASSWORD_FILE_USER'."
            RESTIC_PASSWORD_FILE="$PASSWORD_FILE_USER"
        elif ! is_non_interactive; then
            local pass
            pass=$(prompt_password) ||
                gabyx::die "Could not prompt for password."

            RESTIC_PASSWORD_FILE=$(mktemp -p /dev/shm)
            echo "$pass" >"$RESTIC_PASSWORD_FILE"
        else
            gabyx::die "Could not read password from file '$PASSWORD_FILE_USER' or prompt."
        fi

    else
        gabyx::die "Nor root or user!"
    fi
}

function run_list() {
    set_password_file

    gabyx::print_info "Import all zfs pools"
    gabyx::sudo zpool import -f -a

    gabyx::unmount_zfs zfs-pool-external-ssd data-backups || true
    gabyx::mount_zfs zfs-pool-external-ssd data-backups "external-ssd"

    list_and_check
}

function run_backup() {
    notify "Starting restic backup."
    general_excludes=~/.config/restic/general-excludes.txt

    set_password_file

    gabyx::print_info "Import all zfs pools"
    gabyx::sudo zpool import -f -a

    gabyx::print_info "Mount datasets..."
    for dataset in "${DATASETS[@]}"; do
        gabyx::unmount_zfs zfs-pool-data "$dataset" || true
        gabyx::mount_zfs zfs-pool-data "$dataset" "data"
    done

    gabyx::print_info "Mount targets..."
    gabxy::unmount zfs-pool-external-ssd data-backups || true
    gabxy::mount zfs-pool-external-ssd data-backups "external-ssd" || {
        echo "Did you plugin the external-ssd backup disk?" >&2
        exit 1
    }
    BACKUP_VOLUME_MOUNTED="true"

    backup
}

function unmount_power_off_backup_drive() {
    if [ "$BACKUP_VOLUME_MOUNTED" != "true" ]; then
        return 0
    fi

    echo "Unmount backup drive for safety."
    # Export the pool, will unmount everything.
    gabyx::sudo zpool export zfs-pool-external-ssd

    if [ "$POWEROFF" = "true" ]; then
        echo "Poweroff backup drive for safety."
        # Powerdone external drive.
        gabyx::sudo udisksctl power-off -b "$DISK_PATH"
    fi
}

function clean_up() {
    gabyx::print_info "Clean up..."
    unmount_power_off_backup_drive || true
}

function interrupt() {
    trap - INT
    gabyx::print_info "Interrupt handled."
}

function on_error() {
    notify warning "An error occurred in the backup script."
}

trap interrupt INT
trap clean_up EXIT
trap on_error ERR

parse_args "$@"

if [ "$LIST" = "true" ]; then
    run_list
else
    gabyx::is_root || keep_sudo_alive
    run_backup
fi
