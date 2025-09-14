{
  config,
  pkgs,
  lib,
  ...
}:
let

  inherit (lib) types mkOption;
  cfg = config.settings.backup;

  mkPath =
    vol: dir:
    assert lib.asserts.assertMsg (lib.isString dir) "Path `${dir}` must be string.";
    assert lib.asserts.assertMsg (lib.hasPrefix "/" dir) "Path `${dir}` must have `/` prefix.";
    "${cfg.btrfsSnapshotDir}/${vol}${dir}";

  homeDir = dir: mkPath "home" "/${config.settings.user.name}/${dir}";
  rootDir = dir: mkPath "root" "${dir}";

  paths = [
    (rootDir "/var/lib/NetworkManager")
    (rootDir "/var/lib/AccountsService")

    (rootDir "/persist/music")

    (homeDir "Pictures")
    (homeDir "Documents")
    (homeDir "Downloads")

    # Keyrings
    (homeDir ".local/share/keyrings")

    # Signal
    (homeDir ".config/Signal")

    # Elements
    (homeDir ".config/Element")

    # Evolution
    (homeDir ".config/evolution")
    (homeDir ".local/share/evolution*")

    # Dconf
    (homeDir ".config/dconf")
  ];
in
{
  options = {
    # My settings.
    settings = {
      backup = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };

        name = mkOption {
          default = config.networking.hostName;
          type = types.str;
          apply =
            v:
            assert lib.assertMsg (builtins.match "^[a-z.-]+$" v == [ ]) "Backup name must be '[a-z.-]+'.";
            v;
          description = "The backup name.";
        };

        btrfsVolumes = mkOption {
          default = [
            "/"
            "/home"
            "/persist"
          ];
          type = types.listOf types.str;
          description = "The volumes to first snapshot and backup.";
        };

        btrfsSnapshotDir = mkOption {
          default = "/mnt/snapshots";
          type = types.str;
          description = "Btrfs snapshot directory.";
        };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = builtins.all (
          name: lib.hasAttr name config.fileSystems && config.fileSystems.${name}.fsType == "btrfs"
        ) cfg.btrfsVolumes;
        message = ''
          One or more expected Btrfs subvolumes are missing or not Btrfs!
          Expected volumes: ${lib.concatStringsSep ", " cfg.btrfsVolumes}
        '';
      }
    ];

    age.secrets = lib.mkIf cfg.enable {
      backup-password.file = ./secrets/backup-password.age;

      backup-repository-name.file = ./secrets/backup-repository-${cfg.name}.age;
      backup-storage-known-hosts.file = ./secrets/backup-storage-known-hosts.age;
      backup-storage-ssh-key.file = ./secrets/backup-storage-ssh-ed25519.age;
    };

    # Define the backup.
    services.restic = {
      backups."${cfg.name}" = lib.mkIf cfg.enable {
        initialize = true;

        inherit paths;

        extraBackupArgs = [
          "--skip-if-unchanged"
          "--cleanup-cache"
        ];

        backupPrepareCommand =
          # bash
          ''
            set -eu
            export PATH="${pkgs.btrfs-progs}/bin:$PATH"

            mkdir -p /mnt/backup-snapshots

            for sub in "/" "/home" "/persist" ; do
               name="$sub"
               [ "$sub" = "/" ] && name="root"
               echo "Creating snapshot of '$sub' in /mnt/snapshots"
               btrfs subvolume snapshot -r "$sub" "/mnt/snapshots/$name"
            done
          '';

        backupCleanupCommand =
          # bash
          ''
            set -eu
            export PATH="${pkgs.btrfs-progs}/bin:$PATH"

            for sub in "/" "/home" "/persist" ; do
               name="$sub"
               [ "$sub" = "/" ] && name="root"
              echo "Deleting snapshot of '$sub' in /mnt/snapshots"
              btrfs subvolume delete "/mnt/snapshots/$name"
            done
          '';

        pruneOpts = [
          "--keep-daily 5"
          "--keep-weekly 3"
          "--keep-monthly 2"
        ];

        extraOptions = [
          (
            "sftp.args='-i /run/agenix/backup-storage-ssh-key "
            + "-o UserKnownHostsFile=${config.age.secrets.backup-storage-known-hosts.path}'"
          )
        ];

        passwordFile = config.age.secrets.backup-password.path;
        repositoryFile = config.age.secrets.backup-repository-name.path;

        timerConfig = {
          OnCalendar = "12:00";
        };
      };

    };

    # Extra systemd options to reduce load
    systemd.services."restic-backups-${cfg.name}".serviceConfig = lib.mkIf cfg.enable {
      # Lower CPU priority
      Nice = 19;
      # Lower I/O priority
      IOSchedulingClass = "idle";
    };
  };
}
