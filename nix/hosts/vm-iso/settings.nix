{ ... }:
{
  networking.hostName = "nixos-vm-iso";

  settings = {
    backup = {
      enable = false;
    };
  };
}
