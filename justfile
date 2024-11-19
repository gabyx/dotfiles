set positional-arguments
set shell := ["bash", "-cue"]
root_dir := justfile_directory()

# Get the defined host inside the `.env` file.
[private]
get-host:
    #!/usr/bin/env bash
    set -eu
    cd "{{root_dir}}"
    [ -f .env ] || { echo "Place a .env inside '{{root_dir}}'."; exit 1; }
    source ".env" &>/dev/null && echo "$host"

# Prints the NixOS version (based on nixpkgs repository).
version:
    nixos-version --revision

# NixOS rebuild command for the `host` (defined in the flake).
rebuild how *args:
    #!/usr/bin/env bash
    set -eu
    cd "{{root_dir}}"

    host="${2:-}"
    [ -n "$host" ] || host=$(just get-host) || exit 1

    echo "----"
    echo nixos-rebuild {{how}} --flake ".#$host" --use-remote-sudo "${@:3}"
    echo "----"

    nixos-rebuild {{how}} --flake ".#$host" --use-remote-sudo "${@:3}"

# Switch the `host` (`$1`) to the latest configuration.
switch *args:
    sudo just rebuild switch "${1:-}" "${@:2}"

# Build with nix-output-monitor.
switch-visual *args:
    # We need sudo, because output-monitor will not show the prompt.
    sudo echo "Starting" && \
    just rebuild switch "${1:-}" \
        --show-trace --verbose --log-format internal-json \
        "${@:2}" |& nom --json && \
    just diff 2

# Switch the `host` (`$1`) to the latest
# configuration but under boot entry `test`.
switch-test *args:
    sudo just rebuild switch "${1:-}" -p test "${@:2}"

# Update the flake lock file.
# You can also do `--update-input XXX` to
# only update one input.
update *args:
    cd "{{root_dir}}" && nix flake update "$@"

# Update a single input in the lock file.
update-single *args:
    cd "{{root_dir}}" && nix flake lock --update-input "$@"

# Show the history of the system profile and test profiles.
history:
    #!/usr/bin/env bash
    set -eu
    echo "History in 'system' profile:"
    nix profile history --profile /nix/var/nix/profiles/system

    echo "History in 'test' profile:"
    nix profile history --profile /nix/var/nix/profiles/system-profiles/test

# Run the trim script to reduce the amount of generations kept on the system.
# Usage with `--help`.
trim *args:
    ./scripts/trim-generations.sh {{args}}

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

    if [[ "$last" =~ [0-9]* ]]; then
        last_profile="$(find /nix/var/nix/profiles -type l -name '*system-*' | sort -u | tail "-1" | head -1)"

        if [[ "$(readlink last_profile)" = "$(readlink /nix/var/nix/profiles/current-system)" ]]; then
            echo "Last profile '$last_profile' points to 'nix/var/nix/profiles/current-system' -> Skip."
            last=$(($last + 1)) # skip current system.
        fi

        last_profile="$(find /nix/var/nix/profiles -type l -name '*system-*' | sort -u | tail "-$last" | head -1)"
    else
        last_profile="$last"
    fi

    nvd diff "$last_profile" "$current_profile"

# Run nix-tree to get the tree of all packages.
tree:
    nix-tree

# Diff closures from `dest_ref` to `src_ref`. This builds and
# computes the closure which might take some time.
diff-closure dest_ref="/" src_ref="origin/main" host="":
    #!/usr/bin/env bash
    set -eu

    host="{{host}}"
    [ -n "$host" ] || host=$(just get-host) || exit 1

    echo "Diffing closures of host '$host' from '{{src_ref}}' to '{{dest_ref}}'"

    nix store diff-closures \
        ".?ref={{src_ref}}#nixosConfigurations.$host.config.system.build.toplevel" \
        ".?ref={{dest_ref}}#nixosConfigurations.$host.config.system.build.toplevel"

# Format the whole repository.
format:
    cd "{{root_dir}}" && \
      nix fmt

# Run Nix garbage-collection on the system-profile.
gc:
    echo "Remove test profile"
    sudo rm -rf /nix/var/nix/profiles/system-profile/test

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
    chezmoi encrypt "{{file}}"

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
    pkey=$(secret-tool lookup chezmoi keyfile-private-key 2>/dev/null) && \
        echo "$pkey" | \
            age -d -i - "{{root_dir}}/config/dot_config/chezmoi/key.age" > \
                        ~/.config/chezmoi/key && \
        chezmoi "$@" && \
        rm -rf ~/.config/chezmoi/key || \
        rm -rf ~/.config/chezmoi/key 2>/dev/null

# Store the private-key for the keyfile 'key.age'
# into the keyring.
store-kefile-private-key:
    secret-tool store --label='Chezmoi Key-File Private Key' \
        chezmoi keyfile-private-key

# Delete the script state of chezmoi to rerun scripts.
delete-chezmoi-script-state:
    chezmoi state delete-bucket --bucket scriptState
