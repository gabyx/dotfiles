{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    user.chezmoi.workspace = "work";

    backup = {
      enable = true;
      backups.system.enable = true;
    };
  };
}
