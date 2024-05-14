#!/usr/bin/env bash
# shellcheck disable=SC1090

if [ -f ~/.config/nextmeeting/envrc ]; then
    source ~/.config/nextmeeting/envrc
fi

exec nextmeeting "$@"
