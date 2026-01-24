{
  ...
}:
{
  imports = [
    ./../desktop/configuration-base.nix

    ./disko.nix
    ./../desktop/boot.nix

    ./settings.nix
    ../common/yubikey.nix
  ];
}
