#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u

function get_password_from_keyring() {
    if command -v secret-tool &>/dev/null; then
        secret-tool lookup chezmoi keyfile-private-key 2>/dev/null
    fi
}

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
    rm -rf ~/.config/chezmoi || true
fi

if [ ! -d "$dest" ]; then
    echo "Clone chezmoi for workspae '$workspace'."
    rm -rf ~/.config/chezmoi || true

    git clone --branch "$chezmoiRef" "$chezmoiUrl" "$dest"

    # Make the init pass with the prompt in `.chezmoi.yaml.tmpl`.
    chezmoi init --promptChoice "Workspace?=$workspace"
else
    echo "Chezmoi already setup. To forcefully rerun use:"
    echo " \$ $dest/modules/home/scripts/setup-configs.sh --force '$chezmoiUrl' '$chezmoiRef' '$workspace'"
fi

addArgs=()
if ! get_password_from_keyring &>/dev/null; then
    echo "WARNING: Encrypted files are not applied, " >&2
    echo "because no password entry in keyring with attribute:" >&2
    echo "'chezmoi' and key: 'keyfile-private-key'." >&2
    addArgs=("--exclude" "encrypted")
fi

echo "Apply chezmoi config files."
chezmoi --force \
    --no-tty \
    --no-pager \
    --refresh-externals=never \
    apply "${addArgs[@]}"
