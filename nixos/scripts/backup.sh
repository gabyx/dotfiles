#!/usr/bin/env bash
# shellcheck disable=SC1091
set -e
set -u

restic -r /mnt/linux-backup/persist backup /persist
