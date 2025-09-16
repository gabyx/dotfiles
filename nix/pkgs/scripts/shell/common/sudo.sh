#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

source "$GABYX_LIB_DIR/common/guard.sh" || return
source "$GABYX_LIB_DIR/common/log.sh"

function gabyx::is_root() {
    [ "$(id -u)" == 0 ] || false
}

function gabyx::is_user() {
    local user_id="$1"
    [ "$(id -u)" == "$user_id" ] || false
}

function gabyx::sudo() {
    if ! gabyx::is_root; then
        gabyx::print_debug "Run: sudo $(printf '"%s" ' "$@")"
        sudo "$@"
    else
        gabyx::print_debug "Run: $(printf '"%s" ' "$@")"
        "$@"
    fi
}
