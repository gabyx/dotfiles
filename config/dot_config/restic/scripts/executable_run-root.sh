#!/usr/bin/env bash
# shellcheck disable=SC1090

set -e
set -u

USER_UID=1000

function running_as_root() {
    [ "$(id -u)" == 0 ] || false
}

function running_as_user() {
    [ "$(id -u)" == "$USER_UID" ] || false
}

function run_sudo() {
    if ! running_as_root; then
        gabyx::print_debug "Run: sudo $(printf '"%s" ' "$@")"
        sudo "$@"
    else
        "$@"
    fi
}
