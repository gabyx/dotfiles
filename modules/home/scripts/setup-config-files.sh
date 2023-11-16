#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u

if [ -n "${DRY_RUN:-}" ]; then
    echo "Dry-run: No chezmoi install."
    exit 0
fi

# Change to home.
cd ~

force="false"
[ "$1" != "--force" ] || {
    shift 1
    force="true"
}

workspace="$1"
url="https://github.com/gabyx/dotfiles"
dest=~/.local/share/chezmoi

if [ -d "$dest" ] && [ "$force" = "true" ]; then
    rm -rf "$dest" || true
    rm -rf ~/.config/chezmoi || true
fi

if [ ! -d "$dest" ]; then
    echo "Install chezmoi for workspae '$workspace'."
    chezmoi init --promptChoice "Workspace?=$workspace" "$url"

    chezmoi git lfs pull origin
    git -C "$dest" hooks install --non-interactive
else
    echo "Chezmoi already setup. To forcefully rerun use:"
    echo " \$ $dest/modules/home/scripts/install-chezmoi.sh --force '$workspace'"
fi

echo "Apply chezmoi config files."
chezmoi --refresh-externals=always apply
