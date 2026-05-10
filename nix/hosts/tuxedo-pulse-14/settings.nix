{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    user.chezmoi.workspace = "work";

    windowing = {
      manager = "niri";
    };

    backup = {
      enable = true;
      backups.system.enable = true;
    };
  };
}
