set positional-arguments
set shell := ["bash", "-cue"]
root_dir := justfile_directory()

rebuild how host *args:
    cd "{{root_dir}}" && \
        nixos-rebuild {{how}} --flake .#{{host}} --use-remote-sudo "${@:3}"

switch host *args:
    just rebuild switch "{{host}}" "${@:2}"

switch-debug host *args:
    just rebuild switch "{{host}}" --show-trace --verbose "${@:2}"

switch-test host *args:
    just rebuild switch "{{host}}" -p test "${@:2}"

update:
    cd "{{root_dir}}" && nix flake update

history:
    #!/usr/bin/env bash
    echo "History in 'system' profile:"
    nix profile history --profile /nix/var/nix/profiles/system

    echo "History in 'test' profile:"
    nix profile history --profile /nix/var/nix/profiles/system-profiles/test

trim *args:
    ./scripts/trim-generations.sh {{args}}

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

tree:
    nix-tree

diff-closure dest_ref="/" src_ref="origin/main" host="desktop":
    @echo "Diffing closures of host '{{host}}' from '{{src_ref}}' to '{{dest_ref}}'"

    nix store diff-closures \
        '.?ref={{src_ref}}#nixosConfigurations.{{host}}.config.system.build.toplevel' \
        '.?ref={{dest_ref}}#nixosConfigurations.{{host}}.config.system.build.toplevel'

gc:
    echo "Remove test profile"
    sudo rm -rf /nix/var/nix/profiles/system-profile/test

    echo "Remove all generations older than 7 days"
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

    echo "Garbage collect all unused nix store entries"
    sudo nix store gc --debug
