set positional-arguments
set shell := ["bash", "-cue"]
root_dir := justfile_directory()

# NixOS rebuild command for the `host` (defined in the flake).
rebuild how host *args:
    cd "{{root_dir}}" && \
        nixos-rebuild {{how}} --flake .#{{host}} --use-remote-sudo "${@:3}"

# Switch the `host` to the latest configuration.
switch host *args:
    just rebuild switch "{{host}}" "${@:2}"

# Build with nix-output-monitor.
switch-visual host *args:
    # We need sudo, because output-monitor will not show the prompt.
    sudo echo "Starting" && \
    just rebuild switch "{{host}}" --show-trace --verbose --log-format internal-json \
        "${@:2}" |& nom --json

# Switch the `host` to the latest configuration but under boot entry `test`.
switch-test host *args:
    just rebuild switch "{{host}}" -p test "${@:2}"

# Update the flake lock file.
# You can also do `--update-input XXX` to
# only update one input.
update *args:
    cd "{{root_dir}}" && nix flake update "$@"

# Show the history of the system profile and test profiles.
history:
    #!/usr/bin/env bash
    echo "History in 'system' profile:"
    nix profile history --profile /nix/var/nix/profiles/system

    echo "History in 'test' profile:"
    nix profile history --profile /nix/var/nix/profiles/system-profiles/test

# Run the trim script to reduce the amount of generations kept on the system.
trim *args:
    ./scripts/trim-generations.sh {{args}}

# Diff the profile `current-system` with the last system profile
# to see the differences.
diff last="1" current_profile="/run/current-system":
    #!/usr/bin/env bash
    set -euo pipefail
    last="$1"
    current_profile="$2"

    if [[ "$last" =~ [0-9]* ]]; then
        last_profile="$(find /nix/var/nix/profiles -type l -name '*system*' | sort -u | tail "-$last" | head -1)"
    else
        last_profile="$last"
    fi

    nvd diff "$last_profile" "$current_profile"

# Run nix-tree to get the tree of all packages.
tree:
    nix-tree

# Diff closures from `dest_ref` to `src_ref`. This builds and
# computes the closure which might take some time.
diff-closure dest_ref="/" src_ref="origin/main" host="desktop":
    @echo "Diffing closures of host '{{host}}' from '{{src_ref}}' to '{{dest_ref}}'"

    nix store diff-closures \
        '.?ref={{src_ref}}#nixosConfigurations.{{host}}.config.system.build.toplevel' \
        '.?ref={{dest_ref}}#nixosConfigurations.{{host}}.config.system.build.toplevel'

# Run Nix garbage-collection on the system-profile.
gc:
    echo "Remove test profile"
    sudo rm -rf /nix/var/nix/profiles/system-profile/test

    echo "Remove all generations older than 7 days"
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

    echo "Garbage collect all unused nix store entries"
    sudo nix store gc --debug

# Apply all configs, also encrypted ones.
apply-configs:
    chezmoi apply

# Apply all configs but not encrypted ones.
apply-configs-exclude-encrypted:
    chezmoi apply --exclude encrypted

# Encrypt a file using the encryptiong configured
# in `.chezmoi.yaml`.
# This is using the public key.
[no-cd]
encrypt file:
    chezmoi encrypt "{{file}}"

# Decrypt a file using the encryption configured.
[no-cd]
decrypt file:
    age --decrypt -i "{{root_dir}}/config/dot_config/chezmoi/key.age" "{{file}}"

# Store the private-key for the keyfile 'key.age'
# into the keyring.
store-kefile-private-key:
    secret-tool store --label='Chezmoi Key-File Private Key' \
        chezmoi keyfile-private-key

# Delete the script state of chezmoi to rerun scripts.
delete-chezmoi-script-state:
    chezmoi state delete-bucket --bucket scriptState
