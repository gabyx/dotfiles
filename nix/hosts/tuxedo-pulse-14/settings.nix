{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    user.chezmoi.workspace = "work";
    user.profile = "home-gabyx-work";

    networking = {
      wlan-profiles.enable = true;

      vpn.tailscale.client.enable = true;
    };

    windowing = {
      manager = "sway";
    };

    backup = {
      enable = true;
      backups.system.enable = true;
    };
  };
}
