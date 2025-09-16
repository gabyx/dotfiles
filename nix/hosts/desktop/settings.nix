{ ... }:
{
  networking.hostName = "nixos-desktop";

  settings = {
    backup = {
      backups.system.enable = true;
      backups.data-personal.enable = true;
    };
  };
}
