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

chezmoiUrl="$1"
chezmoiRef="$2"
workspace="$3"
dest=~/.local/share/chezmoi

if [ -d "$dest" ] && [ "$force" = "true" ]; then
    rm -rf "$dest" || true
fi

if [ ! -d "$dest" ]; then
    echo "Clone chezmoi for workspace '$workspace'."
    rm -rf ~/.config/chezmoi || true

    echo "Init chezmoi (clone and init) ..."
    chezmoi init -S "$dest" \
        --branch "$chezmoiRef" "$chezmoiUrl" \
        --recurse-submodules=false \
        --promptChoice "Workspace?=$workspace"

else
    echo "Chezmoi already setup. To forcefully rerun use:"
    echo " \$ $dest/modules/home/scripts/setup.sh --force '$chezmoiUrl' '$chezmoiRef' '$workspace'"
fi

echo "WARNING: Encrypted files are not applied, " >&2
echo "Apply chezmoi config files."
cd "$dest"
just develop-nosec \
    just apply-configs-exclude-encrypted \
    --force \
    --no-tty \
    --no-pager \
    --refresh-externals=never

echo "Chezmoi apply successful."
