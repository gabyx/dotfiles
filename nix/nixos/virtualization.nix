{
  config,
  pkgsUnstable,
  ...
}:
{
  ### Virtualisation ==========================================================
  users.users.${config.settings.user.name}.extraGroups = [
    "libvirtd"
  ];

  # Libvirtd ===============================
  services.qemuGuest.enable = true;
  # boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [
    "kvm-amd"
    "kvm-intel"
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.enable = true;
      runAsRoot = true;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
  users.groups.libvirtd.members = [ config.settings.user.name ];
  # ========================================

  environment.systemPackages = [
    pkgsUnstable.virt-manager
    pkgsUnstable.virt-viewer
  ];

  # Virtualbox
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # ===========================================================================
}
