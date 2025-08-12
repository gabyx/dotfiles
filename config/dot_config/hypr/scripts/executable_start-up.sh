#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034,SC1090,SC2016
# set -e
# set -u

LOG=~/.hyprland-startup.log

# Save stdout and stderr to file
exec 3>&1 4>&2 >"$LOG" 2>&1

dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
systemctl --user start hyprpolkitagent

echo "Finished"
