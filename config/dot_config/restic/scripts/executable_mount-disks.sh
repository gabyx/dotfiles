#!/usr/bin/env bash
# shellcheck disable=SC1090

set -e
set -u

. ~/.config/shell/common/log.sh
. ~/.config/shell/common/platform.sh

. ~/.config/restic/scripts/run-root.sh

function get_mount_point() {
    local -n _mountpoint="$1"

    local os=""
    get_platform_os os

    if [ "$os" = "darwin" ]; then
        _mountpoint=/Volumes
    else
        _mountpoint=/mnt
    fi
}

function mount() {
    local pool="$1"
    local dataset="$2"

    local mountpoint=""
    get_mount_point mountpoint
    local mount="$mountpoint/$3"

    if [ "$(zfs get mounted "$pool/$dataset" -o value -H)" = "yes" ]; then
        gabyx::print_info "Already mounted zfs: $pool, dataset: $dataset"
        return 0
    fi

    gabyx::print_info "Mount zfs: $pool, dataset: $dataset at: '$mount/$dataset"
    run_sudo zfs set -u mountpoint="$mount/$dataset" "$pool/$dataset"
    run_sudo zfs mount -l "$pool/$dataset" || {
        gabyx::die "Could not mount volume '$pool/$dataset'. -> Skip." >&2
    }
}

function unmount() {
    local pool="$1"
    local dataset="$2"

    if [ "$(zfs get mounted "$pool/$dataset" -o value -H)" = "no" ]; then
        gabyx::print_info "Already unmounted zfs: $pool, dataset: $dataset"
        return 0
    fi

    gabyx::print_info "Unmount zfs: $pool, dataset: $dataset"
    run_sudo sudo zfs unmount "$pool/$dataset" ||
        gabyx::die "Could not unmount volume '$pool/$dataset'"

}
