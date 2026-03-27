{
  ...
}:
{
  imports = [
    ./../desktop/configuration-base.nix

    ./../desktop/boot.nix
    ./disko.nix

    ./settings.nix
    ../common/yubikey.nix
  ];
}
