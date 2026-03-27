#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

function gabyx::start_new_browser() {
    google-chrome-stable \
        --user-data-dir="${XDG_CONFIG_DIR:-$HOME/.config}/google-chrome/VPN" >/dev/null 2>&1 &
    disown
}
