#!/usr/bin/env bash
# shellcheck disable=SC1090

set -e
set -u

. ~/.config/shell/common/log.sh
. ~/.config/shell/common/platform.sh

. ~/.config/restic/scripts/mount-disks.sh

DISK_PATH=/dev/disk/by-uuid/4877700394137381369
PERSONAL_SRC=/mnt/data/personal
PERSONAL_DEST=/mnt/external-ssd/data-backups/personal

WORK_SRC=/mnt/data/work
WORK_DEST=/mnt/external-ssd/data-backups/work

# Flags:
LIST="true"
NONINTERACTIVE="false"

function parse_args() {
    # Loop through all the arguments
    for arg in "$@"; do
        case $arg in
        --list)
            LIST="true"
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
}

function restic_backup() {
    local src="$1"
    local dest="$2"

    gabyx::print_info "===============================" \
        "Backing up '$src' to '$dest' with restic."
    (cd "$src" &&
        restic backup -r "$dest" --exclude-file "$general_excludes" ./) ||
        die "Backup failed."
    gabyx::print_info "==============================="
}

function backup_all() {
    echo "Starting backup of all disks..."

    restic_backup "$PERSONAL_SRC" "$PERSONAL_DEST"
    restic_backup "$WORK_SRC" "$WORK_DEST"
    backup_list_and_check
}

function backup_list_and_check() {
    # export_backup_password
    echo "Snapshots for '$PERSONAL_DEST'."
    restic snapshots -r "$PERSONAL_DEST"

    echo "Snapshots for '$WORK_DEST'."
    restic snapshots -r "$WORK_DEST"

    echo "Checks for '$PERSONAL_DEST'."
    restic check -r "$PERSONAL_DEST"

    echo "Checks for '$WORK_DEST'."
    restic check -r "$WORK_DEST"
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

    if [ ! -f "$password_file" ]; then
        RESTIC_PASSWORD=$(prompt_password) ||
            die "Could not prompt for password."
    else
        RESTIC_PASSWORD=$(cat "$password_file")
    fi

    [ -n "$RESTIC_PASSWORD" ] || die "Password is empty."

    export RESTIC_PASSWORD
}

function run_backup_list() {
    export_backup_passwordjj

    gabyx::print_info "Import all zfs pools"
    sudo zpool import -f -a

    unmount zfs-pool-external-ssd data-backups || true
    mount zfs-pool-external-ssd data-backups "external-ssd"

    backup_list_and_check
}

function run_backup() {
    notify "Starting restic backup."
    general_excludes=~/.config/restic/general-excludes.txt

    export_backup_password

    gabyx::print_info "Import all zfs pools"
    sudo zpool import -f -a

    # Mount sources.
    unmount zfs-pool-data work || true
    unmount zfs-pool-data personal || true
    mount zfs-pool-data work "data"
    mount zfs-pool-data personal "data"

    # Mount targets
    unmount zfs-pool-external-ssd data-backups || true
    mount zfs-pool-external-ssd data-backups "external-ssd" || {
        echo "Did you plugin the external-ssd backup disk?" >&2
        exit 1
    }

    backup_all

    # Unmount for sure the encrypted disk.
    unmount zfs-pool-data work
    # unmount zfs-pool-data personal

    notify "Backup finished."
}

function unmount_power_off_backup_drive() {
    # Export the pool, will unmount everything.
    sudo zpool export zfs-pool-external-ssd

    # Powerdone external drive.
    sudo udisksctl power-off -b "$DISK_PATH"
}

function clean_up() {
    echo "Unmount and power off backup drive for safety."
    unmount_power_off_backup_drive &>/dev/null || true
}

function on_error() {
    notify warning "An error occurred in the backup script."
}

trap clean_up EXIT
trap on_error ERROR

if [ "$LIST" = "true" ]; then
    run_backup_list
else
    run_backup
fi
