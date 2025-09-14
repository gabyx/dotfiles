#!/usr/bin/env bash
# shellcheck disable=SC1090

BACKUPS=("nixos-desktop" "nixos-tuxedo" "data-personal")

STATE="none"
STATUS=()

function exists() {
    local unit="$1"
    if systemctl show -p LoadState --value "$unit" 2>/dev/null | grep -q loaded; then
        return 0
    fi

    echo "Unit '$unit' does not exist." >&2
    return 1
}

for name in "${BACKUPS[@]}"; do

    unit="restic-backups-$name.service"
    echo "Checking '$unit'" >&2

    if ! exists "$unit"; then
        continue
    fi

    lastExitTime=$(systemctl show -p ExecMainExitTimestamp "$unit" | sed s/.*=//)

    if systemctl is-active --quiet "$unit" &>/dev/null; then
        STATE="running"
        STATUS+=("- '$name' 🏃🏽‍♀️...")

    elif [ "$(systemctl show -p ExecMainStatus --value "$unit" 2>/dev/null)" = "0" ]; then
        # only set the success status when not running or failure
        [ "$STATE" != "running" ] && [ "$STATE" != "failure" ] &&
            STATE="success"

        STATUS+=("- '$name' 🌻 ($lastExitTime)")
    elif [ "$(systemctl show -p ExecMainStatus --value "$unit" 2>/dev/null)" != "0" ]; then
        [ "$STATE" != "running" ] && STATE="failure"

        STATUS+=("- '$name' 💣 ($lastExitTime)")
    else
        echo "Could not determine status" >&2
        STATUS+=("- '$name' ⁉️($lastExitTime)")
    fi

done

MSG="$(printf '%s\\n' "${STATUS[@]}")"
MSG=$(echo "${STATUS[@]}" | sed '/^$/d')

# shellcheck disable=SC2028
printf '{"class":"%s", "text":"", "alt":"%s", "tooltip":"Backups:\\n%s"}' \
    "$STATE" "$STATE" "$MSG"
