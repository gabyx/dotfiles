{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    user.chezmoi.workspace = "work";

    windowing = {
      manager = "sway";
    };

    backup = {
      enable = true;
      backups.system.enable = true;
    };
  };
}
