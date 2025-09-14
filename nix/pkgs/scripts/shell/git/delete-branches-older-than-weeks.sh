#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2015

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
. "$SCRIPT_DIR/../common/source.sh"

function main() {

    local force="false"
    local remote="true"
    local older_than_weeks="8"

    while [ "$#" -gt 0 ]; do
        case "$1" in
        -f | --force)
            force="true"
            shift
            ;;
        --no-remote)
            remote="false"
            shift
            ;;
        --weeks)
            older_than_weeks="$2"
            shift 2
            ;;
        *)
            # Default case for unknown arguments
            gabyx::print_error "Unknown argument: $1"
            return 1
            ;;
        esac
    done

    if ! [[ $older_than_weeks =~ ^[0-9]+$ ]]; then
        gabyx::print_error "Input needs to be a number."
        return 1
    fi

    gabyx::print_info "Remove all tracking branches no more on remote."
    git fetch -p &&
        git remote prune origin || {
        gabyx::print_error "Could not fetch and prune."
        return 1
    }

    local remote_branches
    remote_branches=$(git ls-remote origin "refs/heads/*" 2>/dev/null | sed -E s@refs/heads/@@g) || {
        gabyx::print_error "Could not get remote branches."
        return 1
    }

    branches=()
    local msg="Would delete"
    if [ "$force" = "true" ]; then
        msg="Delete"
    fi

    gabyx::print_info "Searching for branches with no commit for '$older_than_weeks' weeks."

    for k in $(git branch | sed /\*/d); do
        if [ -z "$(git log -1 --since="$older_than_weeks week ago" -s "$k")" ]; then
            # Contains a commit!
            continue
        fi

        if [[ $remote == "false" ]]; then
            gabyx::print_info "$msg branch '$k'."
            branches+=("$k")
        elif ! echo "$remote_branches" | grep -q "$k"; then
            gabyx::print_info "Branch '$k' does not exist anymore on remote."
            gabyx::print_info "$msg branch '$k'."
            branches+=("$k")
        fi
    done

    for k in "${branches[@]}"; do
        if [ "$force" = "true" ]; then
            git branch -D "$k"
        fi
    done
}

main "$@"
