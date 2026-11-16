{ modulesPath, ... }:
let
  memSize = 16000;
in
{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  # services.qemuGuest.enable = true;

  # Log in as `nixos` on the console without a password.
  services.getty.autologinUser = "nixos";

  disko.memSize = memSize;

  virtualisation = {
    cores = 16;
    memorySize = memSize;

    # No display window: boot log and console on the terminal (serial).
    # Quit QEMU with `Ctrl+a x`.
    graphics = false;

    # Keep builds inside the VM on the disk and not in RAM.
    writableStoreUseTmpfs = false;

    forwardPorts = [
      # Gradient web frontend (nginx).
      {
        from = "host";
        host.address = "127.0.0.1";
        host.port = 8080;
        guest.port = 80;
      }
      # SSH.
      {
        from = "host";
        host.address = "127.0.0.1";
        host.port = 60022;
        guest.port = 22;
      }
    ];
  };
}
