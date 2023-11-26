#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")" && pwd)

LOG="$DIR/.tmux-resurrect-hook.log"

# Save stdout and stderr to file
exec 3>&1 4>&2 >"$LOG" 2>&1

# This three lines are specific to NixOS and they are intended
# to edit the tmux_resurrect_* files that are created when tmux
# session is saved using the tmux-resurrect plugin. Without going
# into too much details the strings that are saved for some applications
# such as nvim, vim, man... when using NixOS, appimage, asdf-vm into the
# tmux_resurrect_* files can't be parsed and restored. This addition
# makes sure to fix the tmux_resurrect_* files so they can be parsed by
# the tmux-resurrect plugin and successfully restored.
#
# Modify resurrect files to contain correct paths for nvim etc.
echo "Replacing tmux resurrect last file..."

resurrectDir=~/.local/share/tmux/resurrect
echo "Before ============="
cat "$resurrectDir/last"

target=$(readlink -f $resurrectDir/last) &&
    sed -E \
        -e "s|nvim --cmd.*ruby.|nvim|g;" \
        -e "s|/etc/profiles/per-user/$USER/bin/||g" \
        -e "s|/home/$USER/.nix-profile/bin/||g" \
        "$target" | sponge "$target"

echo "After  ============="
cat "$resurrectDir/last"
