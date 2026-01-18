{ ... }:
let
  memSize = 5000;
in
{
  services = {
    spice-vdagentd.enable = true;
  };

  disko.memSize = memSize;

  virtualisation = {
    cores = 8;
    memorySize = memSize;

    qemu = {
      options = [
        "-device virtio-gpu"
        # "-display gtk,gl=on"
        # "-device usb-tablet"
        # "-spice port=5900,addr=127.0.0.1,disable-ticketing=on"
        # "-device qxl"
        # "-vga qxl"
      ];
    };
  };
}
