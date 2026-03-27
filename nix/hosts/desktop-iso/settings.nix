{ ... }:
{
  networking.hostName = "nixos-desktop-iso";

  settings = {
    backup = {
      enable = false;
    };
  };
}
