{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    backup = {
      enable = true;
      backups.system.enable = true;
    };

    chezmoi.workspace = "work";
  };
}
