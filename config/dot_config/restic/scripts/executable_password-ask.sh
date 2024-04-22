#!/usr/bin/env bash
# shellcheck disable=SC1091
set -e
set -u

~/.githooks/bin/githooks-dialog entry --title "Restic Backup" --text "Enter the password:" --hide-entry
