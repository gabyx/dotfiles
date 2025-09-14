#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091

. "$GABYX_LIB_DIR/common/source.sh"

# Find recent files in the dir `$1`.
function gabyx::internal::find_recent() {
    local dir="$1"
    shift 1

    fd "$@" --type f "$dir" --exec find {} -printf "%T@ %Td-%Tb-%TY %TT %p\n" |
        sort -n | cut -d " " -f 2-
}
