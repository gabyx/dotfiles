#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u

# All inputs.
tmpDir=""
chezmoiUrl="$1"
chezmoiRef="$2"
workspace="$3"
dest="${4:-$HOME/.local/share/chezmoi}"
force="false"
[ "$1" != "--force" ] || {
    shift 1
    force="true"
}

function cleanup() {
    [ ! -d "$tmpDir" ] || rm -rf "$tmpDir" || true
}

if [ -n "${DRY_RUN:-}" ]; then
    echo "Dry-run: No chezmoi install."
    exit 0
fi

# Change to home.
cd ~

# If the `secrets` submodule is not checked out, fake all secrets
# to make `chezmoi apply ...` work.
function fake_secrets() {
    echo "Fake all secrets in '$PWD'."
    cd config
    rm -rf .secrets && mkdir .secrets

    #shellcheck disable=SC2016
    fd ".*.age$" --type l --exec bash -c \
        'p="{}" && l="$(readlink "{}")" && \
         cd "$(dirname "$p")" && \
         mkdir -p "$(dirname "$l")" && \
         echo "dummy-file" > "$l"'
}

if [ -d "$dest" ] && [ "$force" = "true" ]; then
    rm -rf "$dest" || true
    rm -rf ~/.config/chezmoi || true
fi

if [ ! -d "$dest" ]; then
    echo "Clone chezmoi for workspace '$workspace'."
    rm -rf ~/.config/chezmoi || true

    git clone --branch "$chezmoiRef" "$chezmoiUrl" "$dest"

    # Make the init pass with the prompt in `.chezmoi.yaml.tmpl`.
    echo "Init chezmoi ..."
    cd "$dest"
    chezmoi init --promptChoice "Workspace?=$workspace"
else
    echo "Chezmoi already setup. To forcefully rerun use:"
    echo " \$ $dest/modules/home/scripts/setup.sh --force '$chezmoiUrl' '$chezmoiRef' '$workspace'"
fi

echo "WARNING: Encrypted files are not applied, " >&2

# Copy to temp folder quickly to fake secrets.
tmpDir="$(mktemp -d)"
cp -r "$dest/." "$tmpDir" &&
    cd "$tmpDir" &&
    fake_secrets

echo "Apply chezmoi config files."
chezmoi -S . \
    --force \
    --no-tty \
    --no-pager \
    --refresh-externals=never \
    apply --exclude encrypted

echo "Chezmoi apply successful."
