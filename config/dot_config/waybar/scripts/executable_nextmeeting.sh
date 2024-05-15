#!/usr/bin/env bash
# shellcheck disable=SC1090

if [ -f ~/.config/nextmeeting/envrc ]; then
    source ~/.config/nextmeeting/envrc
fi

if echo "$@" | grep "open-meet"; then
    nextmeeting "$@"
    swaymsg [class='(?i).*chrome.*'] focus
else
    exec nextmeeting "$@"
fi
