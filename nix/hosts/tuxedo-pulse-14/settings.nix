{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    user.chezmoi.workspace = "work";

    networking.wlan-profiles.enable = true;

    windowing = {
      manager = "sway";
    };

    backup = {
      enable = true;
      backups.system.enable = true;
    };
  };
}
