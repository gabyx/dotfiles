{ ... }:
{
  networking.hostName = "nixos-desktop";

  settings = {
    backup = {
      enable = true;
      enablePersist = true;
      backups.system.enable = true;
      backups.data-personal.enable = true;
    };
  };
}
