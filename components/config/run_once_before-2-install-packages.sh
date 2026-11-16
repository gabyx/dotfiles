#!/usr/bin/env bash

set -e
set -u

function install_ubuntu_packages() {
    sudo apt-get install -y \
        git \
        git-lfs \
        coreutils \
        findutils \
        binutils \
        tmux || {
        echo "Could not install packages with 'apt'. Did you install it?" >&2
        exit 1
    }

    brew install \
        chezmoi \
        shfmt shellcheck \
        git-delta \
        age \
        just \
        eza \
        ripgrep \
        codespell \
        typos-cli || {
        echo "Could not install packages with 'brew'. Did you install it?" >&2
        exit 1
    }
}

if [ "$CHEZMOI_OS_RELEASE_ID" = "nixos" ]; then
    true
elif [ "$CHEZMOI_OS_RELEASE_ID" = "ubuntu" ]; then
    # install_ubuntu_packages
    true
else
    echo "WARNING: Architecture '$CHEZMOI_OS' not supported for installing packages." >&2
fi
