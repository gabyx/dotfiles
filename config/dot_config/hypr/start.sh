#!/usr/bin/env bash

# Init the wallpaper daemon.
swww init &

# Set the wallpaper.
wallpaper=~/.local/share/chezmoi/backgrounds/background-space.jpg
if [ -f "$wallpaper" ]; then
    swww img "$wallpaper" &
fi

# Launch the bar.
waybar &
