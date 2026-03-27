#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2015

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
. "$SCRIPT_DIR/../common/log.sh"

function ignore_branch() {
    local branch="$1"
    if [[ $branch =~ (main|master|develop) ]]; then
        return 0
    fi
    return 1
}

function main() {
    local force="false"

    while [ "$#" -gt 0 ]; do
        case "$1" in
        -f | --force)
            force="true"
            shift
            ;;
        *)
            # Default case for unknown arguments
            gabyx::print_error "Unknown argument: $1"
            return 1
            ;;
        esac
    done

    local main_branch="${1:-main}"

    git checkout -q "$main_branch"
    local branches=()

    # Normal merged branches.
    readarray -t bs < <(git for-each-ref --merged "$main_branch" refs/heads/ "--format=%(refname:short)")
    for branch in "${bs[@]}"; do
        if ignore_branch "$branch"; then
            continue
        fi
        gabyx::print_info "Branch '$branch' is merged normally into '$main_branch' and can be deleted."
        branches+=("$branch")
    done

    local squashed_commit
    local tree_sha
    local merge_base

    # Squash merged branches.
    readarray -t bs < <(git for-each-ref --no-merged "$main_branch" refs/heads/ "--format=%(refname:short)")
    for branch in "${bs[@]}"; do
        if ignore_branch "$branch"; then
            continue
        fi

        gabyx::print_debug "Checking branch '$branch'."
        merge_base=$(git merge-base main "$branch") || {
            gabyx::print_warning "Could not get merge-base."
            continue
        }
        tree_sha=$(git rev-parse "$branch^{tree}") || {
            gabyx::print_warning "Could not get tree."
            continue
        }
        squashed_commit=$(git commit-tree "$tree_sha" -p "$merge_base" -m "_") || {
            gabyx::print_warning "Could not create a squash commit."
            continue
        }

        if [[ "$(git cherry main "$squashed_commit")" == "-"* ]]; then
            gabyx::print_info "- '$branch' is merged into '$main_branch' and can be deleted"
            branches+=("$branch")
        fi
    done

    for branch in "${branches[@]}"; do
        if ignore_branch "$branch"; then
            continue
        fi

        if [ "$force" = "true" ]; then
            gabyx::print_info "Deleting branch '$branch' locally and on remote."

            git branch -D "$branch" || gabyx::print_error "Could not delete '$branch'."
            git push --delete origin "$branch" || gabyx::print_warning "Branch does not exist on remote."
        else
            gabyx::print_info "Would delete '$branch' locally and remotely."
        fi
    done
}

main "$@"
