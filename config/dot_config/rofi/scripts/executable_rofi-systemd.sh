#!/usr/bin/env bash

set -eE
set -u

export ROFI_SYSTEMD_TERM="wezterm start"
exec rofi-systemd "$@"
