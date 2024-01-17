#!/usr/bin/env bash
# shellcheck disable=SC1090

set -e
set -u

. ~/.config/shell/common/log.sh
. ~/.config/shell/common/platform.sh

. ~/.config/restic/scripts/mount-disks.sh

function restic_backup() {
    local src="$1"
    local dest="$2"

    print_info "===============================" \
        "Backing up '$src' to '$dest' with restic."
    (cd "$src" &&
        restic backup -r "$dest" --exclude-file "$general_excludes" ./) ||
        die "Backup failed."
    print_info "==============================="
}

function backup() {
    src=/mnt/data/work
    dest=/mnt/external-ssd/data-backups/work

    restic_backup "$src" "$dest"

    src=/mnt/data/personal
    dest=/mnt/external-ssd/data-backups/personal

    restic_backup "$src" "$dest"
}

password_file=~/.config/restic/backup-pass.txt
general_excludes=~/.config/restic/general-excludes.txt

if [ ! -f "$password_file" ]; then
    RESTIC_PASSWORD=$("$HOME/.config/restic/scripts/password-ask.sh") ||
        die "Could not prompt for password."
else
    RESTIC_PASSWORD=$(cat "$password_file")
fi
export RESTIC_PASSWORD

print_info "Import all zfs pools"
sudo zpool import -f -a

# Mount sources.
unmount zfs-pool-data work || true
unmount zfs-pool-data personal || true
mount zfs-pool-data work "data"
mount zfs-pool-data personal "data"

# Mount targets
unmount zfs-pool-external-ssd data-backups || true
mount zfs-pool-external-ssd data-backups "external-ssd"

backup

# Unmount for sure the encrypted disk.
unmount zfs-pool-data work
# unmount zfs-pool-data personal

# Export the pool, will unmount everything.
sudo zpool export zfs-pool-external-ssd

# Powerdone external drive.
sudo udisksctl power-off -b /dev/disk/by-uuid/4877700394137381369
