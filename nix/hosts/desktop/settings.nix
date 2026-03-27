{ ... }:
{
  networking.hostName = "nixos-desktop";

  settings = {
    backup = {
      enable = true;
      backups.system = {
        enable = true;
        enablePersist = true;
      };
      backups.data-personal.enable = true;
    };
  };
}
