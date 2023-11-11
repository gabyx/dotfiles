#!/usr/bin/env bash

set -eE
set -u

function on_error() {
    notify-send --category warning "This script '$0' failed." || true
    exit 1
}

trap cleanup ERR

# Taken from https://github.com/gibbz00/sway-rofi-screenshot/blob/master/sway-rofi-screenshot
# and adapted to grimshot
# which works nicely with sway.

if ! out=$(grimshot check 2>&1); then
    if ! command -v notify-send &>/dev/null; then
        swaynag -t warning -m "Grimshot has not all tools available. Run 'grimshot check'." || true
    else
        notify-send --category warning "Command 'grimshot check' failed:" \
            "$out" || true
    fi

    exit 1
fi

CHOICE=$(
    rofi -dmenu -p 'Screenshot' <<EOF
Active Window
Manual Area
Manual Window
Current Screen
All Screens
EOF
)

WITH_CURSOR=$(
    rofi -dmenu -p 'With Cursor?' -lines 2 <<EOF
yes
no
EOF
)

CURSOR_ARG=""
if [ "$WITH_CURSOR" = "yes" ]; then
    CURSOR_ARG="--cursor"
fi

SAVEDIR=${SWAY_ROFI_SCREENSHOT_SAVEDIR:=$HOME/Pictures}
# Expand potential '~'
SAVEDIR="${SAVEDIR/#\~/$HOME}"
FILENAME="$SAVEDIR/$(date +'%Y-%m-%d-%H%M%S-screenshot.png')"

mkdir -p -- "$(dirname "$FILENAME")"

case "$CHOICE" in
"Active Window")
    grimshot $CURSOR_ARG --notify save active "$FILENAME"
    ;;
"Manual Area")
    grimshot $CURSOR_ARG --notify save area "$FILENAME"
    ;;
"Manual Window")
    grimshot $CURSOR_ARG --notify save window "$FILENAME"
    ;;
"Current Screen")
    grimshot $CURSOR_ARG --notify save output "$FILENAME"
    ;;
"All Screens")
    grimshot $CURSOR_ARG --notify save screen "$FILENAME"
    ;;
'')
    notify-send "Screenshot" "Cancelled"
    exit 0
    ;;
*)
    notify-send "Screenshot" "Cancelled"
    exit 0
    ;;
esac

# If swappy is installed, prompt the user to edit the captured screenshot
if command -v swappy $ >/dev/null; then
    EDIT_CHOICE=$(
        rofi -dmenu -p 'Edit the shot?' -lines 2 <<EOF
yes
no
EOF
    )
    case "$EDIT_CHOICE" in
    yes)
        swappy -f "$FILENAME" -o "$FILENAME"
        ;;
    no) ;;
    '') ;;
    esac
fi

wl-copy <"$FILENAME"
notify-send "Screenshot" "File saved as <i>'$FILENAME'</i> and copied to the clipboard." -i "$FILENAME"
