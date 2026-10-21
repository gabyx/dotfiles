{
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko

    ./../desktop/configuration-base.nix
    ./disko.nix

    ./settings.nix
    ../common/yubikey.nix
  ];
}
