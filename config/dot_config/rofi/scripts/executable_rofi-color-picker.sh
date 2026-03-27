#!/usr/bin/env bash

set -eE
set -u

function show_error() {
    if ! command -v notify-send &>/dev/null; then
        msg="$(echo -e "$@")"
        swaynag -t warning -m "$msg" || true
    else
        notify-send --category warning "$@" || true
    fi
}

function assert_exe() {
    local exe="$1"
    if ! command -v "$exe" &>/dev/null; then
        show_error "Executable '$exe' not found. Did you install it?"
        exit 1
    fi
}

function on_error() {
    show_error "Screenshot failed" "Script '$0' failed."
    exit 1
}

function start_on_screen_pick() {
    assert_exe hyprpicker
    local color
    color=$(hyprpicker -a --render-inactive)

    [ -z "$color" ] ||
        notify-send "Color copied to your clipboard." "Color '$color' " || true
}

function start_colorwheel() {
    assert_exe gcolor3
    gcolor3
}

trap on_error ERR
assert_exe rofi

CHOICE=$(
    rofi -dmenu -p 'Color-Picking' <<EOF
On Screen Pick
Colorwheel
EOF
) || exit 0

case "$CHOICE" in
"On Screen Pick")
    start_on_screen_pick
    ;;
"Colorwheel")
    start_colorwheel
    ;;
esac
