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

if [ -d ~/.local/share/chezmoi ] && [ "$force" = "true" ]; then
    chezmoi purge --force
fi

if [ ! -d ~/.local/share/chezmoi ]; then
    echo "Install chezmoi for workspae '$workspace'."
    chezmoi init "$url" --promptChoice "Workspace?=$workspace"
    chezmoi git lfs pull origin
else
    echo "Chezmoi already setup. To forcefully rerun use:"
    echo " $ ~/nixos-config/home/scripts/install-chezmoi.sh --force '$workspace'"
fi

echo "Apply chezmoi config files."
chezmoi --refresh-externals=always apply
