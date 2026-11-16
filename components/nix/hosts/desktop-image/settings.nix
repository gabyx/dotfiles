{ ... }:
{
  networking.hostName = "nixos-desktop-iso";

  settings = {
    secrets.enable = false;

    backup = {
      enable = false;
    };
  };
}
