{ ... }:
{
  networking.hostName = "nixos-vm";

  settings = {
    secrets.enable = false;

    backup = {
      enable = false;
    };
  };
}
