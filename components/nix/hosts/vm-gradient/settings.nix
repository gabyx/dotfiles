{ ... }:
{
  networking.hostName = "nixos-vm-gradient";

  settings = {
    user.profile = "home-vm";
    secrets.enable = false;
  };
}
