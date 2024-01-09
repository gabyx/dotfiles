# Run as `just deploy desktop`
deploy host:
  nixos-rebuild switch --flake .#{{host}} --use-remote-sudo

deploy-debug host:
  nixos-rebuild switch --flake .#{{host}} --use-remote-sudo --show-trace --verbose

deploy-test host:
  nixos-rebuild switch --flake .#{{host}} --use-remote-sudo -p test

update:
  nix flake update

history:
  echo "History in 'system' profile:"
  nix profile history --profile /nix/var/nix/profiles/system

  echo "History in 'test' profile:"
  nix profile history --profile /nix/var/nix/profiles/system-profiles/test

trim *ARGS:
  ./scripts/trim-generations.sh {{ARGS}}

diff dest_ref="HEAD" src_ref="origin/main" host="desktop":
    @echo "Diffing closures of host '{{host}}' from '{{src_ref}}' to '{{dest_ref}}'"

    nix store diff-closures \
        '.?ref={{src_ref}}#nixosConfiguration.{{host}}.config.system.build.toplevel' \
        '.?ref={{dest_ref}}#nixosConfiguration.{{host}}.config.system.build.toplevel'

gc:
  echo "Remove test profile"
  sudo rm -rf /nix/var/nix/profiles/system-profile/test

  echo "Remove all generations older than 7 days"
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

  echo "Garbage collect all unused nix store entries"
  sudo nix store gc --debug
