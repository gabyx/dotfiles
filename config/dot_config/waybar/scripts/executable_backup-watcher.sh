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
function last_status() {
    local name="$1"
    # break long lines.
    tail -1 "/var/lib/backups/${name}/status" 2>/dev/null |
        sed 's/.\{80\}/&\\n  /g' || true
}

function snapshot_count() {
    local name="$1"
    c=$(jq -r '.| length' "/var/lib/backups/${name}/snapshots")

    if [ -z "$c" ]; then
        echo "    · snapshots: not synced ⁉️"
    elif [ "$c" -gt 0 ]; then
        echo "    · snapshots: $c 😎"
    elif [ "$c" -eq 0 ]; then
        echo "    · snapshots: $c ❌"
    fi
}

for name in "${BACKUPS[@]}"; do

    unit="restic-backups-$name.service"
    echo "Checking '$unit'" >&2

    if ! exists "$unit"; then
        continue
    fi

    status=$(last_status "$name")
    count=$(snapshot_count "$name")

    if [[ ! "$(systemctl is-active "$unit")" =~ inactive|failed ]]; then
        STATE="running"
        STATUS+=("· 🏃🏽‍♀️ '$name' ..." "$count" "")
    else
        if echo "$status" | grep -q "success"; then
            # only set the success status when not running or failure
            [ "$STATE" != "running" ] && [ "$STATE" != "failure" ] &&
                STATE="success"

            STATUS+=("· $status" "$count" "")
        elif echo "$status" | grep -q "failure"; then
            [ "$STATE" != "running" ] && STATE="failure"

            STATUS+=("· $status" "$count")
        else
            echo "Could not determine status" >&2
            [ "$STATE" != "running" ] && STATE="failure"
            STATUS+=("· ⁉️ '$name'" "$count" "")
        fi
    fi
done

MSG="$(printf '%s\\n' "${STATUS[@]}")"
MSG=$(echo "$MSG" | sed '/^$/d')

# shellcheck disable=SC2028
printf '{"class":"%s", "text":"", "alt":"%s", "tooltip":"Backups:\\n%s"}' \
    "$STATE" "$STATE" "$MSG"
