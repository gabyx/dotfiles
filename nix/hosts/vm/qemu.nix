{ ... }:
{
  virtualisation.cores = 8;
  virtualisation.memorySize = 5000;

  virtualisation.qemu = {
    options = [
      "-device virtio-gpu"
      "-display gtk,gl=on"
      # "-device usb-tablet"
      # "-spice port=5900,addr=127.0.0.1,disable-ticketing=on"
      # "-device qxl"
      # "-vga qxl"
    ];
  };
}
