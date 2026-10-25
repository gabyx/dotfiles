{
  ...
}:
{
  imports = [
    ./../desktop/configuration-base.nix
    ./disko.nix

    ./settings.nix
    ../common/yubikey.nix

    ./usb-bootable.nix
  ];
}
