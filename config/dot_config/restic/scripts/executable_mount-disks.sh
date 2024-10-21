#!/usr/bin/env bash
# shellcheck disable=SC1090

set -e
set -u

. ~/.config/shell/common/log.sh
. ~/.config/shell/common/platform.sh

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

    gabyx::print_info "Mount zfs: $pool, dataset: $dataset at: '$mount/$dataset"
    sudo zfs set -u mountpoint="$mount/$dataset" "$pool/$dataset"
    sudo zfs mount -l "$pool/$dataset" || {
        echo
        echo "Could not mount volume '$mount/$dataset'. -> Skip." >&2
    }
}

function unmount() {
    local pool="$1"
    local dataset="$2"

    gabyx::print_info "Unmount zfs: $pool, dataset: $dataset"
    sudo zfs unmount "$pool/$dataset"
}
