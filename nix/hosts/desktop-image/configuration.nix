{
  ...
}:
{
  imports = [
    ./../desktop/configuration-base.nix
    ./../desktop/disko.nix

    ./settings.nix
    ../common/yubikey.nix

    ./usb-bootable.nix
  ];
}
