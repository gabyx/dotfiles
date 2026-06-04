#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

function gabyx::start_new_browser() {
    zen-browser \
        --profile "${XDG_CONFIG_DIR:-$HOME/.config}/zen/VPN" >/dev/null 2>&1 &
    disown
}
