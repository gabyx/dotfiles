{ ... }:
{

  services = {
    spice-vdagentd.enable = true;
  };

  virtualisation = {
    cores = 8;
    memorySize = 5000;

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
