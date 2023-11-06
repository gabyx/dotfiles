#!/usr/bin/env bash

cliphist list |
    rofi -c ~/.config/rofi/config-clipboard.rasi \
        -dmenu -p "Select item to delete" -lines 10 -width 35 |
    cliphist delete
