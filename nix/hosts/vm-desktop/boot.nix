{
  ...
}:
{
  boot = {
    loader.grub = {
      # no need to set devices,
      # disko will add all devices that have a EF02 partition to the list already
      devices = [ ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    ### Temp Files ==============================================================
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
    # ===========================================================================

    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_blk"
    ];

    initrd.kernelModules = [ ];

    kernelModules = [
      "kvm"
      "kvm-intel"
      "kvm-arm"
    ];

    extraModulePackages = [ ];
  };
}
