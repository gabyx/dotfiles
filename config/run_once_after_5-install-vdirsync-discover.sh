#!/usr/bin/env bash

set -e
set -u

echo "Syncing calendars..."
echo " - Run 'vdirsync discover' ..."

if ! command -v vdirsyncer &>/dev/null; then
    echo "INFO: 'vdirsyncer' is not installed. Will not run discover." >&2
    exit 0
fi

vdirsyncer discover
