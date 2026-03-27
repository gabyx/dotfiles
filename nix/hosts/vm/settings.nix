{ ... }:
{
  networking.hostName = "nixos-vm";

  settings = {
    backup = {
      enable = false;
    };
  };
}
