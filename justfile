set positional-arguments
set dotenv-load := true
set shell := ["bash", "-cue"]
root_dir := justfile_directory()
build_dir := root_dir / "build"

mod vm "./tools/just/vm.just"

# The host for which most commands work below.
default_host := env("NIXOS_HOST", "not-defined")

# If the nix-output-monitor should be used.
use_nom := env("USE_NOM", "true")

# Default command to list all commands.
list:
    just --list

# Enter a development shell to ensure all tools are here.
alias dev := develop
develop *args:
    #!/usr/bin/env bash
    set -eu
    flake_dir="."
    shell="default";
    args=("$@") && [ "${#args[@]}" != 0 ] ||
        args=(env SHELL="$SHELL" "$SHELL")

    nix develop \
        --accept-flake-config \
        "$flake_dir#$shell" \
        --command "${args[@]}"

# Format the whole repository.
format:
    cd "{{root_dir}}" && \
      nix fmt

# Build the NixOS.
build *args:
    #!/usr/bin/env bash
    set -eu
    host="{{default_host}}"
    cmd=(nix build
        --verbose
        --show-trace
        ".#nixosConfigurations.$host.config.system.build.toplevel"
        "$@"
    )

    echo "----"
    echo "${cmd[@]}"
    echo "----"

    if [ "{{use_nom}}" = "true" ]; then
        "${cmd[@]}" --log-format internal-json |& nom --json
    else
        "${cmd[@]}"
    fi

# Builds
build-image *args:
    #!/usr/bin/env bash
    set -eu
    host="{{default_host}}"
    package="$host-image"

    # Build without submodules (no secrets!)
    cmd=(nix build
        --verbose
        --show-trace
        ".#$package"
        "$@"
    )

    echo "----"
    echo "${cmd[@]}"
    echo "----"

    if [ "{{use_nom}}" = "true" ]; then
        "${cmd[@]}" --log-format internal-json |& nom --json
    else
        "${cmd[@]}"
    fi

# Show NixOS options for a certain host.
option opts *args:
    nixos-option -F ".#{{default_host}}" "{{opts}}" "${@:2}"

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
    just rebuild boot "$@"

# Switch the `host` (`$1`) to the latest configuration.
switch *args:
    just rebuild switch "$@"
    just diff 2

# Build with nix-output-monitor.
switch-visual *args:
    #!/usr/bin/env bash
    set -eu
    just rebuild switch \
        --show-trace \
        --verbose \
        "$@"

    just diff 2

# Switch to the latest configuration of the `host` (`$2`)
# but under boot entry `name`.
switch-test name="test" *args:
    #!/usr/bin/env bash
    set -eu
    just rebuild switch -p "{{name}}"  \
        --show-trace \
        --verbose \
        "${@:2}"

    just diff 2 "{{name}}"

# Build the host `$2` and put it under the boot entry `name`.
boot-test name="test" *args:
    #!/usr/bin/env bash
    set -eu
    just rebuild boot -p "{{name}}"  \
        --show-trace \
        --verbose \
        "${@:2}"


    just diff 2 "{{name}}"

# NixOS rebuild command for the `host` (defined in the flake).
[private]
rebuild how *args:
    #!/usr/bin/env bash
    set -eu
    cd "{{root_dir}}"

    host="{{default_host}}"
    cmd=(nixos-rebuild {{how}}
        --flake ".#$host"
        "${@:2}"
    )

    echo "Checkout all LFS files."
    git lfs checkout
    echo "Fetch all submodules."
    git submodule update --recursive --init

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

    if [ -s /nix/var/nix/profiles/system-profiles/music ]; then
        echo "History in 'music' profile:"
        nix profile history --profile /nix/var/nix/profiles/system-profiles/music
    fi

# Run the trim script to reduce the amount of generations kept on the system.
# Usage with `--help`.
trim *args:
    ./tools/scripts/trim-generations.sh "$@"

# Diff the profile `current-system` with the last system profile
# to see the differences.
# `last` can be an number or a path to the link in `/nix/var/nix/profiles/...`
diff last="1" profile_name="system" current_profile="/run/current-system":
    #!/usr/bin/env bash
    set -eu

    if ! command -v nvd &>/dev/null; then
        echo "! Command 'nvd' not installed to print difference." >&2
        exit 0
    fi

    set -euo pipefail
    last="$1" # skip current system.
    profile_name="$2"
    current_profile="$3"

    function sort_profiles() {
        find /nix/var/nix/profiles -type l -name "*${profile_name}-*" -printf '%T@ %p\0' |
        sort -zk 1nr |
        sed -z 's/^[^ ]* //' |
        tr '\0' '\n'
    }

    if [[ "$last" =~ [0-9]* ]]; then
        last_profile="$(sort_profiles | head -n "$last" | tail -n 1)"

        if [[ "$(realpath "$last_profile")" == "$(realpath /run/current-system)" ]]; then
            echo "Last profile '$last_profile' points to '/run/current-system' -> Skip."
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

    echo "Remove steam profile"
    sudo rm -rf /nix/var/nix/profiles/system-profiles/steam
    sudo rm -rf /nix/var/nix/profiles/system-profiles/steam-*

    echo "Remove all generations older than 7 days"
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 60d
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/music

    echo "Garbage collect all unused nix store entries"
    sudo nix store gc --debug

# Start the NixOS.
start host="vm" remote_viewer="false":
    #!/usr/bin/env bash
    set -eu
    host="${1:-}"
    if [ -z "$host" ]; then
        host="{{default_host}}"
    fi

    out_dir="{{build_dir}}/$host"
    mkdir -p "$out_dir"

    cmd=(nix build \
        --out-link "$out_dir/vmWithDisko" \
        --show-trace --verbose --log-format internal-json \
        "{{root_dir}}#nixosConfigurations.$host.config.system.build.vmWithDisko")

    echo "----"
    echo "${cmd[@]}"
    echo "----"

    "${cmd[@]}" |& nom --json

    qemu_args=()
    if [ "{{remote_viewer}}" = "true" ]; then
        qemu_args+=(
            -spice unix=on,addr=$out_dir/spice.sock,disable-ticketing=on
            -device virtio-serial-pci
            -chardev spicevmc,id=ch1,name=vdagent
            -device virtserialport,chardev=ch1,name=com.redhat.spice.0
        )

        echo "IMPORTANT: ----------------------"
        echo "IMPORTANT: Connect with 'remote-viewer spice+unix://$out_dir/spice.sock'"
        echo "IMPORTANT: ----------------------"
    else
        qemu_args+=(
            -display gtk,gl=on
        )
    fi

    if [ ! -f "$out_dir/vmWithDisko/bin/disko-vm" ]; then
        echo "Host '$host' not build. Use 'just build'."
    fi

    echo "Starting with '$out_dir/vmWithDisko/bin/disk-vm"

    # FIXME: Forward qemu opts like this: https://github.com/nix-community/disko/pull/1142
    QEMU_OPTS="${qemu_args[@]}" "$out_dir/vmWithDisko/bin/disko-vm"


diff-to-main:
    git fetch origin && \
    git diff origin/main...HEAD

# Apply all configs, also encrypted ones.
apply-configs *args:
    just cm apply "$@"

# Apply all configs but not encrypted ones.
apply-configs-exclude-encrypted *args:
    chezmoi -S "." apply --exclude encrypted "$@"

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

# Move all regular files in the repo to the secret folder.
move-all-to-secrets:
    #!/usr/bin/env bash
    set -eu

    # Remove all links, recreat them from secrets.
    fd ".*.age$" -E "secrets/**" --type l --exec rm "{}"

    fd ".*.age$" --type f ./secrets \
        --exec just create-links-from-secrets "{}"

    fd ".*.age$" -E "secrets/**" --type f \
        --exec just move-to-secrets "{}"

# Move a file to the secrets folder.
[private]
move-to-secrets file:
    #!/usr/bin/env bash
    set -eu
    file="{{file}}"
    d="$(dirname "$file")";
    mkdir -p "secrets/$d";
    cp "$file" "secrets/$file";
    rm "$file";
    ln -s "$(realpath --relative-to="$d" "secrets/$file")" "$file"

# Align file name of link to secrets.
[private]
create-links-from-secrets file:
    #!/usr/bin/env bash
    set -eu
    file="{{file}}"
    file_rel="${file#*secrets/}"

    link="$file_rel"
    d="$(dirname "$file_rel")"
    points_to="$(realpath --relative-to="$d" "$file")"

    # Only add the link if there is no such file existing.
    # If it exists we re-added it in chezmoi.
    if [ ! -f "$link" ]; then
        ln -s "$points_to" "$link"
    fi

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

    mkdir -p ~/.config/chezmoi
    echo "$pkey" | \
        age -d -i - "{{root_dir}}/config/dot_config/chezmoi/key.age" > \
                    ~/.config/chezmoi/key

    if echo "$@" | grep -q "re-add"; then
        echo "WARNING: Run 'just move-all-to-secrets'!!"
    fi

    chezmoi -S "." "$@"


# Store the private-key for the keyfile 'key.age'
# into the keyring.
store-private-key:
    secret-tool store --label='Chezmoi Key-File Private Key' \
        chezmoi keyfile-private-key

# Delete the script state of chezmoi to rerun scripts.
delete-chezmoi-script-state:
    chezmoi -S "." state delete-bucket --bucket scriptState
