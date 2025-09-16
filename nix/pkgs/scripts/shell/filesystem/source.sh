#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_FILESYSTEM:-}" != "loaded" ]; then
    function gabyx::find_recent() {
        gabyx::shell-run "gabyx::internal::find_recent" "$@"
    }

    # Mount all ZFS disks.
    function gabyx::mount_zfs_disks() {
        gabyx::shell-run "$GABYX_LIB_DIR/filesystem/mount-zfs-disks.sh" "$@"
    }

    # Unmount all ZFS disks.
    function gabyx::unmount_zfs_disks() {
        gabyx::shell-run "$GABYX_LIB_DIR/filesystem/mount-zfs-disks.sh" --unmount "$@"
    }

    # Run the backup script.
    function gabyx::backup_zfs() {
        gabyx::shell-run "$GABYX_LIB_DIR/filesystem/backup.sh" "$@"
    }

    # List all backups.
    function gabyx::list_backups() {
        gabyx::shell-run "$GABYX_LIB_DIR/filesystem/backup.sh" --list
    }

    GABYX_LIB_FILESYSTEM="loaded"
fi
