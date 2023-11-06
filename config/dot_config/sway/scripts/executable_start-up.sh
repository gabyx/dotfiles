#!/usr/bin/env bash
# shellcheck disable=SC1091
set -e
set -u

# if [ ! -f ~/python-envs/sway/bin/activate ]; then
#     python3 -m venv ~/python-envs/sway
#     source ~/python-envs/sway/bin/activate
#     pip install i3ipc
# else
#     source ~/python-envs/sway/bin/activate
# fi

# Startup when launching sway.
echo "Starting mail."
swaymsg "workspace '8 Mail'; exec thunderbird;"
sleep 3

echo "Starting web."
swaymsg "workspace '9 Web'; exec firefox;"
sleep 3

echo "Starting comm."
swaymsg "workspace '7 Comm'; exec signal-desktop;"
