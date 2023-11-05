#!/usr/bin/env bash

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

rofi -show powermenu \
     -modi "powermenu:$DIR/scripts/rofi-power-menu.sh --symbols-font 'JetBrainsMono Nerd Font'"

