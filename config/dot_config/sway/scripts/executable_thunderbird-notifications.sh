#!/usr/bin/env bash

# Get thunderbird notification window id and focus!
readarray -t notifications_window_ids < <(swaymsg -t get_tree |
    jq \
        '. as $in | . |
    paths(select(type == "object" and has("name") and (.name | match(".*reminder.*"; "i")))) |
    . as $path |
    ($in | getpath($path) ) | .id')

for id in "${notifications_window_ids[@]}"; do
    echo "Focusing notification thunderbird window id: '$id'"
    swaymsg "[con_id=$id] focus"
done
