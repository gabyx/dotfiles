{
  inputs,
  ...
}:
{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix

    ./configuration-base.nix

    ./disko.nix
    ./settings.nix
  ];
}
