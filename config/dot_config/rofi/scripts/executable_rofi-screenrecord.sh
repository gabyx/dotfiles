#!/usr/bin/env bash

set -eE
set -u

function show_info() {
    printf "%s\n" "$@"
    notify-send --category info "$@" || true
}

function show_error() {
    printf "%s\n" "$@" >&2
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
        show_error "Executable '$exe' not found" "Did you install it?"
        exit 1
    fi
}

function stop_recorder() {
    if ! pkill --euid "$USER" --signal SIGINT wf-recorder; then
        show_error "Could not stop wf-recorder. Is it running?"
    fi
}

function start_record_manual() {
    # Get selection and honor escape key
    local coords
    coords=$(slurp) || {
        cancel "Cancelled screen selection."
        return 1
    }

    show_info "Start recording." "File '$FILE_PATH_VIDEO'."

    # Capture video using slup for screen area
    # timeout and exit after 10 minutes as user has almost certainly forgotten it's running
    timeout 600 wf-recorder -g "$coords" -f "$FILE_PATH_VIDEO" || {
        cancel "Cancelled screen recording" "-> timeout!"
        return 1
    }

    show_info "Recording saved." "File '$FILE_PATH_VIDEO'."

    # Produce a palette from the video file
    ffmpeg -i "$FILE_PATH_VIDEO" \
        -filter_complex "palettegen=stats_mode=full" \
        "$FILE_PATH_PALETTE" -y || {
        show_error "Computing palette from recording failed."
        return 1
    }

    # Use palette to produce a gif from the video file
    ffmpeg -i "$FILE_PATH_VIDEO" \
        -i "$FILE_PATH_PALETTE" \
        -filter_complex "paletteuse=dither=sierra2_4a" \
        "$FILE_PATH_GIF" -y || {
        show_error "Computing GIF from recording failed."
        return 1
    }

    return 0
}

function cancel() {
    local msg="$1"
    show_error "$msg"
    [ -d "$SAVE_DIR" ] && rm -rf "$SAVE_DIR"
}

function on_exit() {
    [ ! -f "$FILE_PATH_PALETTE" ] || rm -f "$FILE_PATH_PALETTE"
}

function on_error() {
    show_error "Record Screen failed" "Script '$0' failed."
    exit 1
}

trap on_exit EXIT
trap on_error ERR

# Define paths
SAVE_DIR="$HOME/Videos/$(date +'%Y-%m-%d-%H%M%S-recording')"
FILE_PATH_VIDEO="$SAVE_DIR/recording.mp4"
FILE_PATH_PALETTE="$SAVE_DIR/palette.png"
FILE_PATH_GIF="$SAVE_DIR/palette.gif"
LOG="$SAVE_DIR/log.txt"

assert_exe wf-recorder
assert_exe ffmpeg
assert_exe pkill

CHOICE=$(
    rofi -dmenu -p 'Screen Record' <<EOF
Manual Area
Stop Recording
EOF
) || exit 0

case "$CHOICE" in
"Manual Area")
    mkdir -p "$SAVE_DIR"
    start_record_manual &>"$LOG"
    ;;
"Stop Recording") stop_recorder ;;
'')
    exit 0
    ;;
*)
    exit 0
    ;;
esac

echo "Finished"
