#!/usr/bin/env bash
# =========================================================================================
# Chezmoi Setup
#
# @date 17.3.2023
# @author Gabriel Nützi, gnuetzi@gmail.com
# =========================================================================================

function die() {
    echo -e "!! $1" >&2
    exit 1
}

[ -n "$1" ] || die "No argument given!"

#shellcheck disable=SC2015
git check-attr filter "$1" | grep -q 'lfs' &&
    git check-attr diff "$1" | grep -q 'lfs' &&
    git check-attr merge "$1" | grep -q 'lfs' &&
    git check-attr text "$1" | grep -q 'unset' &&
    echo "✓ Path is already LFS tracked: '$1'" ||
    die "✗✗✗ Path is NOT LFS tracked: '$1'\n-> Edit '.gitattributes' and let it review!"

return 0
