#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034
#
# Guard: only allow sourcing in Bash
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script must be sourced in Bash." >&2
    return 1 2>/dev/null
fi
