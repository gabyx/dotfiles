{
  inputs,
  ...
}:
{
  imports = [
    ./configuration-base.nix

    ./hardware-configuration.nix
    ./boot.nix
    ./settings.nix

    inputs.self.nixosModules.networking-profiles
    inputs.self.nixosModules.secrets
  ];
}
