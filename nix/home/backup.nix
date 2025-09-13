{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  homeDir =
    dir:
    assert lib.asserts.assertMsg (lib.isString dir) "Var `dir` must be string.";
    osConfig.settings.user.home + "/" + dir;

  backupKnownHosts = ./secrets/backup-storage-known-host;

  backup = osConfig.settings.backup;
in
{
  age.secrets = lib.mkIf backup.enable {
    backup-password = ./secrets/backup-password.age;
    backup-storage-ssh-key = ./secrets/backup-storage-ssh-ed25519.age;
    "backup-repository-${backup.name}" = ./secrets/backup-password-${backup.name}.age;
  };

  services.openssh.knownHosts = {
    backupHost = {
      hostNames = [ "your-host.example.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...";
    };
  };

  # Define the backup.
  services.restic = {
    enable = backup.enable;

    backups."${backup.name}" = {
      initialize = true;

      paths = [
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

        "/persist/music"
      ];

      exclude = [
      ];

      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 3"
        "--keep-monthly 2"
      ];

      extraOptions = [
        "sftp.args='-i /run/agenix/backup-storage-ssh-key' -o 'UserKnownHostFile=${backupKnownHosts}'"
      ];

      passwordFile = config.age.secrets.backup-password;
      repositoryFile = config.age.secrets."backup-repository-${backup.name}";

      timerConfig = {
        OnCalendar = "10:00";
      };
    };
  };
}
