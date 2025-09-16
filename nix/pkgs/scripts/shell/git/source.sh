#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_GIT:-}" != "loaded" ]; then
    # Deletes branches which have not received any commit for a '$1' weeks (default 8).
    # Will only delete if there is no branch on the remote with the same name
    function gabyx::delete_merged_branches() {
        gabyx::shell-run "$GABYX_LIB_DIR/git/delete-merged-branches.sh" "$@"
    }

    # Deletes local branches (and also remotely)
    # which have not received any commit for a '$1' weeks (default 8).
    # Will only delete if there is no branch on the remote with the same name
    function gabyx::delete_branches_older_than_weeks() {
        gabyx::shell-run "$GABYX_LIB_DIR/git/delete-branches-older-than-weeks.sh" "$@"
    }

    GABYX_LIB_GIT="loaded"
fi
