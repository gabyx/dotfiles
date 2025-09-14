#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

. "$GABYX_LIB_DIR/common/source.sh"

function gabyx::mountpoint_zfs() {
    local -n _mountpoint="$1"

    local os=""
    get_platform_os os

    if [ "$os" = "darwin" ]; then
        _mountpoint=/Volumes
    else
        _mountpoint=/mnt
    fi
}

function gabyx::mount_zfs() {
    local pool="$1"
    local dataset="$2"

    local mountpoint=""
    gabyx::mountpoint_zfs mountpoint
    local mount="$mountpoint/$3"

    if [ "$(zfs get mounted "$pool/$dataset" -o value -H)" = "yes" ]; then
        gabyx::print_info "Already mounted zfs: $pool, dataset: $dataset"
        return 0
    fi

    gabyx::print_info "Mount zfs: $pool, dataset: $dataset at: '$mount/$dataset"
    gabyx::sudo zfs set -u mountpoint="$mount/$dataset" "$pool/$dataset"
    gabyx::sudo zfs mount -l "$pool/$dataset" || {
        gabyx::die "Could not mount volume '$pool/$dataset'. -> Skip." >&2
    }
}

function gabyx::unmount_zfs() {
    local pool="$1"
    local dataset="$2"

    if [ "$(zfs get mounted "$pool/$dataset" -o value -H)" = "no" ]; then
        gabyx::print_info "Already unmounted zfs: $pool, dataset: $dataset"
        return 0
    fi

    gabyx::print_info "Unmount zfs: $pool, dataset: $dataset"
    gabyx::sudo sudo zfs unmount "$pool/$dataset" ||
        gabyx::die "Could not unmount volume '$pool/$dataset'"

}
