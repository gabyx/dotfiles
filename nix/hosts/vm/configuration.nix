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

    inputs.self.modules.nixos.networking-profiles
    inputs.self.modules.nixos.secrets
  ];
}
