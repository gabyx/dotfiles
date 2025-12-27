{
  config,
  outputs,
  system,
  pkgs,
  lib,
  ...
}:
let

  inherit (lib) types mkOption;
  cfg = config.settings.backup;

  gabyx-shell-source = outputs.packages.${system}.gabyx-shell-source;
in
{
  options =
    let
      defName =
        name:
        mkOption {
          default = name;
          type = types.str;
          apply =
            v:
            assert lib.assertMsg (builtins.match "^[a-z.-]+$" v == [ ]) "Backup name must be '[a-z.-]+'.";
            v;
          description = "The backup name.";
        };

      defRepo =
        bk:
        mkOption {
          default = "${cfg.storageURL}//home/backups/${bk.name}";
          type = types.str;
          description = "The backup repository URL.";
        };

      defReportDir =
        bk:
        mkOption {
          type = types.str;
          default = "${cfg.reportDir}/${bk.name}";
        };
    in
    {
      # My settings.
      settings = {
        backup = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };

          storageURL = mkOption {
            type = types.str;
            default = "sftp://u492021@u492021.your-storagebox.de:23";
          };

          reportDir = mkOption {
            type = types.str;
            default = "/var/lib/backups";
          };

          backups = {
            data-personal = {
              enable = mkOption {
                type = types.bool;
                default = false;
              };

              name = defName "data-personal";
              repository = defRepo cfg.backups.data-personal;
              reportDir = defReportDir cfg.backups.data-personal;
            };

            # Backup the system.
            system = {
              enable = mkOption {
                type = types.bool;
                default = false;
              };

              enablePersist = mkOption {
                type = types.bool;
                default = false;
              };

              name = defName config.networking.hostName;
              repository = defRepo cfg.backups.system;
              reportDir = defReportDir cfg.backups.system;

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
      };
    };

  config =
    let
      mkSysPath =
        vol: dir:
        assert lib.asserts.assertMsg (lib.isString dir) "Path `${dir}` must be string.";
        assert lib.asserts.assertMsg (lib.hasPrefix "/" dir) "Path `${dir}` must have `/` prefix.";
        "${cfg.backups.system.btrfsSnapshotDir}/${vol}${dir}";

      homeDir = dir: mkSysPath "home" "/${config.settings.user.name}/${dir}";
      rootDir = dir: mkSysPath "root" "${dir}";
      persistDir = dir: mkSysPath "persist" "/${dir}";

      excludeMacOS = [
        ".DS_Store"
        ".AppleDouble*"
        "._*"
        ".DocumentRevisions*"
        ".Spotlight-*"
        ".fseventsd*"
        ".TemporaryItem*"
        ".Trash*"
        ".VolumeIcon*"
        ".PKInstallSandboxManager"
      ];

      exclude = excludeMacOS;

      extraOptions = [
        (
          # These arguments get passed as `restic -o <arg>`.
          "sftp.args='-i ${config.age.secrets.backup-storage-ssh-key.path} -o "
          + "UserKnownHostsFile=${config.age.secrets.backup-storage-known-hosts.path}'"
        )
      ];

      passwordFile = config.age.secrets.backup-password.path;

      extraBackupArgs = [
        "--skip-if-unchanged"
        "--cleanup-cache"
        "-v"
      ];

      serviceName = bk: "restic-backups-${bk.name}";

      fetchService =
        bk:
        let
          extraOpts = lib.concatMapStrings (arg: "-o ${arg}") extraOptions;
        in
        {
          "${serviceName bk}-fetch-snapshots" = {
            description = "Backup fetch status.";

            path = [
              config.programs.ssh.package
            ];

            script =
              # bash
              ''
                set -eu
                mkdir -p '${bk.reportDir}'

                resticCmd=(
                '${lib.getExe config.services.restic.backups.${bk.name}.package}'
                ${extraOpts}
                --password-file "${passwordFile}"
                -r '${bk.repository}'
                )

                echo "Fetching snapshots from '${bk.repository}' -> '${bk.reportDir}/snapshots'"
                "''${resticCmd[@]}" snapshots --json > '${bk.reportDir}/snapshots'
              '';
          };
        };

      fetchServiceTimer =
        bk:
        let
          name = "${serviceName bk}-fetch-snapshots";
        in
        {
          ${name} = {
            description = "Run backup fetch every 10 minutes.";
            partOf = [ "${name}.service" ];
            timerConfig = {
              OnBootSec = "3min";
              OnUnitActiveSec = "10min";
            };
            wantedBy = [ "timers.target" ];
          };
        };

    in
    {
      assertions = [
        {
          assertion =
            cfg.backups.system.enable
            -> builtins.all (
              name: lib.hasAttr name config.fileSystems && config.fileSystems.${name}.fsType == "btrfs"
            ) cfg.backups.system.btrfsVolumes;

          message = ''
            One or more expected Btrfs subvolumes are missing or not Btrfs!
            Expected volumes: ${lib.concatStringsSep ", " cfg.btrfsVolumes}
          '';
        }
      ];

      age.secrets = lib.mkIf (cfg.enable) {
        backup-password.file = builtins.path {
          path = ./secrets/backup-password.age;
        };
        backup-storage-known-hosts.file = builtins.path {
          path = ./secrets/backup-storage-known-hosts.age;
        };
        backup-storage-ssh-key.file = builtins.path {
          path = ./secrets/backup-storage-ssh-ed25519.age;
        };
      };

      # Define the backup.
      services.restic = {
        backups."${cfg.backups.system.name}" =
          let
            bk = cfg.backups.system;
          in
          lib.mkIf bk.enable {
            initialize = true;

            paths = [
              (rootDir "/var/lib/NetworkManager")
              (rootDir "/var/lib/AccountsService")

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
            ]
            ++ (lib.optionals bk.enablePersist [
              # Persistent Repos
              (persistDir "music")
              (persistDir "repos/chezmoi")
              (persistDir "repos/technical-markdown")
              (persistDir "repos/technical-presentation")
              (persistDir "repos/grsframework")
              (persistDir "repos/technical-presentation-sdsc")
              (persistDir "repos/technical-presentation-private")
              (persistDir "repos/githooks")
              (persistDir "repos/githooks-*")
              (persistDir "repos/quitsh")
              (persistDir "repos/kikist")
              (persistDir "repos/executiongraph")
              (persistDir "repos/notes")
              (persistDir "repos/cpp-playground")
              (persistDir "repos/rs-playground")
              (persistDir "repos/applications")
              (persistDir "repos/dissertation")
            ]);

            inherit exclude;

            backupPrepareCommand =
              # bash
              ''
                set -eu
                export PATH="${pkgs.btrfs-progs}/bin:$PATH"

                mkdir -p /mnt/snapshots

                for sub in ${lib.escapeShellArgs bk.btrfsVolumes} ; do
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

            inherit extraBackupArgs;
            inherit extraOptions;
            inherit passwordFile;
            inherit (bk) repository;

            timerConfig = {
              OnCalendar = "*-*-* 12:00:00";
            };
          };

        backups.data-personal =
          let
            bk = cfg.backups.data-personal;
          in
          lib.mkIf bk.enable {
            initialize = true;

            paths = [
              "/mnt/data/personal"
            ];

            inherit exclude;

            backupPrepareCommand =
              # bash
              ''
                export PATH="${gabyx-shell-source}/bin:$PATH"
                set -eu
                eval "$(gabyx::shell-source)"
                gabyx::mount_zfs_disks personal

                # Force the kernel to read all directory entries.
                # Such that the stuff is there.
                ls -R /mnt/data/personal >/dev/null
                sleep 5
              '';

            backupCleanupCommand =
              # bash
              ''
                export PATH="${gabyx-shell-source}/bin:$PATH"
                set -eu
                eval "$(gabyx::shell-source)"
                gabyx::unmount_zfs_disks personal
              '';

            pruneOpts = [
              "--keep-daily 5"
              "--keep-weekly 3"
              "--keep-monthly 2"
            ];

            inherit extraBackupArgs;
            inherit extraOptions;
            inherit passwordFile;
            inherit (bk) repository;

            timerConfig = {
              OnCalendar = "*-*-* 12:00:00";
            };
          };
      };

      # Extra systemd jobs & configs.
      systemd.services = lib.mkIf cfg.enable (
        let
          loadBalanceConfig = {
            # Lower CPU priority
            Nice = 19;
            # Lower I/O priority
            IOSchedulingClass = "idle";
          };

          reportService =
            bk: status:
            let
              reportFile = "${bk.reportDir}/status";
              icon = if status == "failure" then "💣" else "🌻";

              report =
                pkgs.writeShellScriptBin ''report''
                  #bash
                  ''
                    set -eu
                    mkdir -p '${cfg.reportDir}' && touch '${reportFile}' &&
                      chmod -R 644 '${reportFile}' # Make it readable for user.

                    echo "${icon} '${bk.name}' ${status} ($(date)) " | \
                      '${pkgs.coreutils}/bin/tee' -a '${reportFile}';
                  '';
            in
            {
              "${serviceName bk}-report-${status}" = {
                description = "Backup report hook.";
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = "${report}/bin/report";
                };
              };
            };

          createServices =
            bk:
            lib.optionalAttrs bk.enable (
              {
                # Create some reducing load settings.
                ${serviceName bk} = lib.mkMerge [
                  {
                    serviceConfig = loadBalanceConfig;
                    onSuccess = [
                      "${serviceName bk}-fetch-snapshots.service"
                      "${serviceName bk}-report-success.service"
                    ];
                    onFailure = [
                      "${serviceName bk}-fetch-snapshots.service"
                      "${serviceName bk}-report-failure.service"
                    ];
                  }
                ];
              }
              // reportService bk "failure"
              // reportService bk "success"
              // fetchService bk
            );
        in
        lib.concatMapAttrs (name: bk: createServices bk) cfg.backups
      );

      # Some timers for the fetch snapshots.
      systemd.timers = lib.mkIf cfg.enable (
        let
        in
        lib.concatMapAttrs (name: bk: fetchServiceTimer bk) cfg.backups
      );
    };
}
