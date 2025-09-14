#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
#
# Mount all ZFS disks.

set -u
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
. "$SCRIPT_DIR/../common/source.sh"
. "$SCRIPT_DIR/zfs.sh"

gabyx::print_info "Import all ZFS pools and mount disks."
sudo zpool import -f -a

unmount="false"
if [ "${1:-}" = "--unmount" ]; then
    shift 1
    unmount=true
fi

what_datasets="${1:-personal}"

# Mount sources.
if [[ $what_datasets =~ work|all ]]; then
    gabyx::unmount_zfs zfs-pool-data work || true
    if [ "$unmount" = "false" ]; then
        gabyx::mount_zfs zfs-pool-data work "data"
    fi
fi

if [[ $what_datasets =~ personal|all ]]; then
    gabyx::unmount_zfs zfs-pool-data personal || true
    if [ "$unmount" = "false" ]; then
        gabyx::mount_zfs zfs-pool-data personal "data"
    fi
fi

if [[ $what_datasets =~ backups|all ]]; then
    gabyx::unmount_zfs zfs-pool-external-ssd data-backups || true
    if [ "$unmount" = "false" ]; then
        gabyx::mount_zfs zfs-pool-external-ssd data-backups \
            "external-ssd"
    fi
fi
