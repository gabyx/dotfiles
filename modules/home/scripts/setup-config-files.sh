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

chezmoiStore="$1"
chezmoiURL="$2"
workspace="$3"
dest=~/.local/share/chezmoi

if [ -d "$dest" ] && [ "$force" = "true" ]; then
    rm -rf "$dest" || true
    rm -rf ~/.config/chezmoi || true
fi

if [ ! -d "$dest" ]; then
    echo "Copy chezmoi for workspae '$workspace' from store '$chezmoiStore'."
    rm -rf ~/.config/chezmoi || true

    cp -r "$chezmoiStore" "$dest"
    git -C "$dest" remote set-url origin "${chezmoiURL}"

    # Make the init pass with the prompt in `.chezmoi.yaml.tmpl`.
    chezmoi init --promptChoice "Workspace?=$workspace"
else
    echo "Chezmoi already setup. To forcefully rerun use:"
    echo " \$ $dest/modules/home/scripts/install-chezmoi.sh --force '$chezmoiStore' '$chezmoiURL' '$workspace'"
fi

echo "Apply chezmoi config files."
chezmoi --refresh-externals=never --verbose apply
