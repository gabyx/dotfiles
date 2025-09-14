# This file is not part of the NixOS configuration and
# is only used for `agenix -e` which encrypts secrets over `age`
# with these public keys.
let
  chezmoi = "age1messaj8qqseag2nuvr5d453qqnkszt3rmwldvpjw8fapd0xfkajs7x6mld";

  # Host Keys (Desktop)
  # Private key must be placed manually.
  hostDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpmbTaLprMrAofmt2vmF3qlB0Kah2qLRQKv4zJ+pmS7 nixos@linux-nixos";

  # TODO: Add tuxedo.

  backup = {
    # Restic backup repository password.
    "backup-password.age".publicKeys = [
      chezmoi
      hostDesktop
    ];
    # Restic backup repository URL.
    "backup-repository-nixos-desktop.age".publicKeys = [
      chezmoi
      hostDesktop
    ];
    # Restic backup repository URL.
    "backup-repository-nixos-tuxedo.age".publicKeys = [
      chezmoi
      hostDesktop
    ];
    # SSH Access to the backup storage.
    "backup-storage-ssh-ed25519.age".publicKeys = [
      chezmoi
      hostDesktop
    ];
    "backup-storage-ssh-ed25519.pub.age".publicKeys = [
      chezmoi
      hostDesktop
    ];
    "backup-storage-known-hosts.age".publicKeys = [
      chezmoi
      hostDesktop
    ];
  };
in
backup
