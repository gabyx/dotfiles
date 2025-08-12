set positional-arguments
set dotenv-load := true
set shell := ["bash", "-cue"]
root_dir := justfile_directory()

# The host for which most commands work below.
default_host := env("NIXOS_HOST", "not-defined")

# Default command to list all commands.
list:
    just --list

# Format the whole repository.
format:
    cd "{{root_dir}}" && \
      nix fmt

# Build the NixOS.
build host="":
    #!/usr/bin/env bash
    set -eu
    host="${1:-}"
    if [ -z "$host" ]; then
        host="{{default_host}}"
    fi

    cmd=(nix build
        --verbose
        --show-trace
        ".#nixosConfigurations.$host.config.system.build.toplevel"
    )

    echo "----"
    echo "${cmd[@]}"
    echo "----"

    "${cmd[@]}"

## Flake maintenance commands =================================================
# Update the flake lock file. Use arguments to specify single inputs.
update *args:
    cd "{{root_dir}}" && nix flake update "$@"

## NixOS Commands to execute on NixOS systems =================================
# Prints the NixOS version (based on nixpkgs repository).
version:
    nixos-version --revision

# Build the new configuration and set it the boot default.
boot *args:
    just rebuild boot "${1:-}" "${@:2}"

# Switch the `host` (`$1`) to the latest configuration.
switch *args:
    just rebuild switch "${1:-}" "${@:2}"
    just diff 2

# Build with nix-output-monitor.
switch-visual *args:
    #!/usr/bin/env bash
    set -eu
    just rebuild switch "${1:-}" \
        --show-trace \
        --verbose \
        --log-format internal-json \
        "${@:2}" |& nom --json

    just diff 2

# Switch the `host` (`$1`) to the latest
# configuration but under boot entry `test`.
switch-test *args:
    #!/usr/bin/env bash
    set -eu
    just rebuild switch "${1:-}" -p test  \
        --show-trace \
        --verbose \
        "${@:2}"

    just diff 2

# Build the new configuration under the boot entry `test`.
boot-test *args:
    #!/usr/bin/env bash
    set -eu
    just rebuild boot "${1:-}" -p test  \
        --show-trace \
        --verbose \
        "${@:2}"

    just diff 2

# NixOS rebuild command for the `host` (defined in the flake).
[private]
rebuild how host *args:
    #!/usr/bin/env bash
    set -eu
    cd "{{root_dir}}"

    host="${2:-}"
    if [ -z "$host" ]; then
        host="{{default_host}}"
    fi
    cmd=(nixos-rebuild {{how}}
        --flake ".#$host"
        --use-remote-sudo "${@:3}"
    )

    echo "----"
    echo "${cmd[@]}"
    echo "----"

    "${cmd[@]}"

# Show the history of the system profile and test profiles.
history:
    #!/usr/bin/env bash
    set -eu
    echo "History in 'system' profile:"
    nix profile history --profile /nix/var/nix/profiles/system

    if [ -s /nix/var/nix/profiles/system-profiles/test ]; then
        echo "History in 'test' profile:"
        nix profile history --profile /nix/var/nix/profiles/system-profiles/test
    fi

# Run the trim script to reduce the amount of generations kept on the system.
# Usage with `--help`.
trim *args:
    ./tools/scripts/trim-generations.sh {{args}}

# Diff the profile `current-system` with the last system profile
# to see the differences.
diff last="1" current_profile="/run/current-system":
    #!/usr/bin/env bash
    set -eu

    if ! command -v nvd &>/dev/null; then
        echo "! Command 'nvd' not installed to print difference." >&2
        exit 0
    fi

    set -euo pipefail
    last="$1" # skip current system.
    current_profile="$2"

    function sort_profiles() {
        find /nix/var/nix/profiles -type l -name '*system-*' -printf '%T@ %p\0' |
        sort -zk 1nr |
        sed -z 's/^[^ ]* //' |
        tr '\0' '\n'
    }

    if [[ "$last" =~ [0-9]* ]]; then
        last_profile="$(sort_profiles | head -n "$last" | tail -n 1)"

        if [[ "$(readlink last_profile)" = "$(readlink /nix/var/nix/profiles/current-system)" ]]; then
            echo "Last profile '$last_profile' points to 'nix/var/nix/profiles/current-system' -> Skip."
            last=$(($last + 1)) # skip current system.
        fi

        last_profile="$(sort_profiles | head -n "$last" | tail -n 1)"
    else
        last_profile="$last"
    fi

    nvd diff "$last_profile" "$current_profile"

# Diff closures from `dest_ref` to `src_ref`. This builds and
# computes the closure which might take some time.
diff-closure dest_ref="/" src_ref="origin/main" host="{{host}}":
    #!/usr/bin/env bash
    set -eu

    host="{{host}}"
    echo "Diffing closures of host '$host' from '{{src_ref}}' to '{{dest_ref}}'"

    nix store diff-closures \
        ".?ref={{src_ref}}#nixosConfigurations.$host.config.system.build.toplevel" \
        ".?ref={{dest_ref}}#nixosConfigurations.$host.config.system.build.toplevel"

# Run nix-tree to get the tree of all packages.
tree *args:
    nix-tree "$@"

# Run Nix garbage-collection on the system-profile.
gc:
    echo "Remove test profile"
    sudo rm -rf /nix/var/nix/profiles/system-profiles/test
    sudo rm -rf /nix/var/nix/profiles/system-profiles/test-*

    echo "Remove all generations older than 7 days"
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

    echo "Garbage collect all unused nix store entries"
    sudo nix store gc --debug

diff-to-main:
    git fetch origin && \
    git diff origin/main...HEAD

# Apply all configs, also encrypted ones.
apply-configs:
    just cm apply

# Apply all configs but not encrypted ones.
apply-configs-exclude-encrypted:
    chezmoi apply --exclude encrypted

# Encrypt a file using the encrypting configured
# in `.chezmoi.yaml`.
# This is using the public key.
[no-cd]
encrypt file:
    just cm encrypt "{{file}}"

# Decrypt a file using the encryption configured.
# You need `store-kefile-private-key` executed.
# This does actually the following:
# pkey=$(secret-tool lookup chezmoi keyfile-private-key 2>/dev/null) && \
# echo "$pkey" | age -d -i - "{{root_dir}}/config/dot_config/chezmoi/key.age" | age -d -i - "{{file}}"
[no-cd]
decrypt file:
    just cm decrypt {{file}}

# Decrypt and edit the file.
# You need `store-kefile-private-key` executed.
[no-cd]
decrypt-edit file:
    just cm edit "{{file}}"

# This is a wrapper to `chezmoi` which provided the necessary encryption
# key temporarily and deletes it afterwards again.
# This is only used for invocations which need the private key.
# This needs `store-kefile-private-key` to be run.
[no-cd]
cm *args:
    #!/usr/bin/env bash
    set -u
    set -e

    trap cleanup EXIT
    function cleanup() {
        rm -rf ~/.config/chezmoi/key 2>/dev/null || true
    }

    pkey=$(secret-tool lookup chezmoi keyfile-private-key) || true
    if [ -z "$pkey" ]; then
        echo "You did not execute 'just store-private-key'!" >&2
        exit 1
    fi

    echo "$pkey" | \
        age -d -i - "{{root_dir}}/config/dot_config/chezmoi/key.age" > \
                    ~/.config/chezmoi/key && \
    chezmoi "$@" && cleanup || cleanup

# Store the private-key for the keyfile 'key.age'
# into the keyring.
store-private-key:
    secret-tool store --label='Chezmoi Key-File Private Key' \
        chezmoi keyfile-private-key

# Delete the script state of chezmoi to rerun scripts.
delete-chezmoi-script-state:
    chezmoi state delete-bucket --bucket scriptState
