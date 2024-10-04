{
  config,
  pkgs,
  ...
}:
{
  # Enable bluetooth
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };

  services.blueman.enable = true;
}
