#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_WINDOWING:-}" != "loaded" ]; then

    # Print the keycodes of the active keyboard.
    function gabyx::print_keycode_table {
        xmodmap -pke
    }

    # Get a keycode from a keypress.
    function gabyx::get_keycode {
        xev
    }

    # Get the window tree in JSON format in `sway`.
    function gabyx::get_window_properties {
        swaymsg -t get_tree | jq
    }

    # Get information on the input device from `sway`.
    function gabyx::get_input_properties {
        local device_type="${1:-touchpad}"
        swaymsg -t get_inputs --raw | jq ".[] | select(.type==\"$device_type\")"
    }

    GABYX_LIB_WINDOWING="loaded"
fi
