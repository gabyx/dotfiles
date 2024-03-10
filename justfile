set positional-arguments
set shell := ["bash", "-cue"]
root_dir := justfile_directory()

rebuild how host *ARGS:
  nixos-rebuild {{how}} --flake .#{{host}} --use-remote-sudo {{ARGS}}

switch host *ARGS:
  nixos-rebuild switch --flake .#{{host}} --use-remote-sudo {{ARGS}}

switch-debug host *ARGS:
  nixos-rebuild switch --flake .#{{host}} --use-remote-sudo --show-trace --verbose {{ARGS}}

switch-test host *ARGS:
  nixos-rebuild switch --flake .#{{host}} --use-remote-sudo -p test {{ARGS}}

update:
  nix flake update

history:
  echo "History in 'system' profile:"
  nix profile history --profile /nix/var/nix/profiles/system

  echo "History in 'test' profile:"
  nix profile history --profile /nix/var/nix/profiles/system-profiles/test

trim *ARGS:
  ./scripts/trim-generations.sh {{ARGS}}

diff last="1" current_profile="/nix/var/nix/profiles/system":
  #!/usr/bin/env bash
  set -euo pipefail

  [ -n "${last_profile:-}" ] || \
      last_profile="$(find /nix/var/nix/profiles -type l -name '*system*' | sort -u | tail "-{{last}}" | head -1)"
  nvd diff "$last_profile" "{{current_profile}}";

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
