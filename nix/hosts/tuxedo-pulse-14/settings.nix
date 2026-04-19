{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    user.chezmoi.workspace = "work";

    windowing = {
      manager = "hyprland";
    };

    backup = {
      enable = true;
      backups.system.enable = true;
    };
  };
}
