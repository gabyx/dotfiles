# This file is not part of the NixOS configuration and
# is only used for `agenix -e` which encrypts secrets over `age`
# with these public keys.
let
  chezmoi = "age1messaj8qqseag2nuvr5d453qqnkszt3rmwldvpjw8fapd0xfkajs7x6mld";

  # Host Keys (Desktop)
  hostDesktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpmbTaLprMrAofmt2vmF3qlB0Kah2qLRQKv4zJ+pmS7 nixos@linux-nixos";

  # TODO: Add tuxedo.
in
{
  # The name corresponds to a corresponding `age.secrets.secret1.file` entry
  # somewhere in the NixOS configuration which defines encrypted file.
  "backup-password.age".publicKeys = [
    chezmoi
    hostDesktop
  ];

  "backup-repository-desktop.age".publicKeys = [
    chezmoi
    hostDesktop
  ];
  "backup-repository-tuxedo.age".publicKeys = [
    chezmoi
    hostDesktop
  ];
  "backup-storage-ssh-ed25519.age".publicKeys = [
    chezmoi
    hostDesktop
  ];
  "backup-storage-ssh-ed25519.pub.age".publicKeys = [
    chezmoi
    hostDesktop
  ];
}
