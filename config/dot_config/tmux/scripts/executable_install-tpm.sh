#!/usr/bin/env bash

tpmFolder="$(cd && pwd)/.config/tmux/plugins/tpm"

if [ ! -d "$tpmFolder" ]; then
    base=$(dirname "$tpmFolder")
    echo "Cloning TPM into '$tpmFolder'."

    mkdir -p "$base" &&
        git clone --single-branch --depth 1 https://github.com/tmux-plugins/tpm "$tpmFolder"
    echo "Successfully cloned."
fi
