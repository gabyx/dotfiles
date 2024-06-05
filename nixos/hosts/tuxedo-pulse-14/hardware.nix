{
  config,
  pkgs,
  ...
}: {
  # Enable bluetooth
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };

  services.blueman.enable = true;

  # Enable tuxedo-rs and tuxedo-keyboard kernel modul.
  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
    tuxedo-keyboard.enable = true;
  };
}
