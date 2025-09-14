#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# shellcheck disable=SC2154,SC2086

function gabyx::_print() {
    local color="$1"
    local flags="$2"
    local header="$3"
    shift 3

    local hasColor="0"
    if [ "${FORCE_COLOR:-}" != 1 ]; then
        [ -t 1 ] && hasColor="1"
    else
        hasColor="1"
    fi

    if [ "$hasColor" = "0" ] || [ "${LOG_COLORS:-}" = "false" ]; then
        local msg
        msg=$(printf '%b\n' "$@")
        msg=${msg//$'\n'/$'\n'   }
        echo $flags -e "-- $header$msg"
    else
        local s=$'\033' e='[0m'
        local msg
        msg=$(printf "%b\n" "$@")
        msg=${msg//$'\n'/$'\n'   }
        echo $flags -e "${s}${color}-- $header$msg${s}${e}"
    fi
}

function gabyx::print_debug() {
    gabyx::_print "[38;5;240m" "" "" "$@"
}

function gabyx::print_info() {
    gabyx::_print "[0;94m" "" "" "$@"
}

function gabyx::print_warning() {
    gabyx::_print "[0;31m" "" "WARN: " "$@" >&2
}

function gabyx::print_prompt() {
    gabyx::_print "[0;32m" "-n" "" "$@" >&2
}

function gabyx::print_error() {
    gabyx::_print "[0;31m" "" "ERROR: " "$@" >&2
}

function gabyx::die() {
    gabyx::print_error "$@"
    exit 1
}
