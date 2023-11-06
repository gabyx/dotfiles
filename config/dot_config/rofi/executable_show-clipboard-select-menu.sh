#!/usr/bin/env bash

cliphist list | rofi -dmenu -p "Select item to copy" -lines 10 -width 35 |
    cliphist decode | wl-copy
