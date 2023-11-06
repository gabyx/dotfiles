#!/usr/bin/env bash

cliphist list |
    rofi -c ~/.config/rofi/config-clipboard.rasi \
        -dmenu -p "Select item to copy" -lines 10 -width 35 |
    cliphist decode | wl-copy
