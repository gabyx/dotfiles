#!/usr/bin/env bash

set -eE
set -u

function show_error() {
    if ! command -v notify-send &>/dev/null; then
        msg="$(echo -e "$@")"
        swaynag -t warning -m "$msg" || true
    else
        notify-send --category warning "$@" || true
    fi
}

function assert_exe() {
    local exe="$1"
    if ! command -v "$exe" &>/dev/null; then
        show_error "Executable '$exe' not found. Did you install it?"
        exit 1
    fi
}

function on_error() {
    show_error "Screenshot failed" "Script '$0' failed."
    exit 1
}

trap on_error ERR

# Taken from https://github.com/gibbz00/sway-rofi-screenshot/blob/master/sway-rofi-screenshot
# and adapted to grimshot
# which works nicely with sway.

assert_exe grimshot
assert_exe rofi

if ! out=$(grimshot check 2>&1); then
    show_error "Grimshot has not all tools available. Run 'grimshot check':\n$out."
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
) || exit 0

WITH_CURSOR=$(
    rofi -dmenu -p 'With Cursor?' -lines 2 <<EOF
no
yes
EOF
) || exit 0

CURSOR_ARG=""
if [ "$WITH_CURSOR" = "yes" ]; then
    CURSOR_ARG="--cursor"
fi

# If swappy is installed, prompt the user to
# edit the captured screenshot
EDIT_CHOICE="no"
if command -v swappy $ >/dev/null; then
    EDIT_CHOICE=$(
        rofi -dmenu -p 'Edit the shot?' -lines 2 <<EOF
no
yes
EOF
    )
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
    exit 0
    ;;
*)
    exit 0
    ;;
esac

case "$EDIT_CHOICE" in
yes)
    swappy -f "$FILENAME" -o "$FILENAME"
    ;;
no) ;;
'') ;;
esac

# Copyq if available has some trouble when
# copying to big images, therefore disable it an load it manually
if command -v "copyq" 2>/dev/null; then
    copyq disable
fi

# Write to wayland clibboard
wl-copy -t image/png <"$FILENAME"

if command -v "copyq" 2>/dev/null; then
    copyq write image/png - <"$FILENAME"
    copyq enable
fi

notify-send "Screenshot" \
    "File saved as <i>'$FILENAME'</i> and copied to the clipboard." -i "$FILENAME" ||
    true
