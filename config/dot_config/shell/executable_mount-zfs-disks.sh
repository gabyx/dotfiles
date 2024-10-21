#!/usr/bin/env bash
# shellcheck disable=SC1090
#
# Mount all ZFS disks.

set -u
set -e

. ~/.config/shell/common/log.sh
. ~/.config/restic/scripts/mount-disks.sh

gabyx::print_info "Import all ZFS pools and mount disks."
sudo zpool import -f -a

unmount="false"
if [ "${1:-}" = "--unmount" ]; then
    shift 1
    unmount=true
fi

what_datasets="${1:-all}"

# Mount sources.
if [[ $what_datasets =~ work|all ]]; then
    unmount zfs-pool-data work || true
    if [ "$unmount" = "false" ]; then
        mount zfs-pool-data work "data"
    fi
fi

if [[ $what_datasets =~ personal|all ]]; then
    unmount zfs-pool-data personal || true
    if [ "$unmount" = "false" ]; then
        mount zfs-pool-data personal "data"
    fi
fi
