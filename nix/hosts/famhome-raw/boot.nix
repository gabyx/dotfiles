{
  config,
  ...
}:
{
  boot = {

    # Bootloader ================================================================
    loader = {
      grub = {
        enable = true;
        device = "nodev"; # The special value nodev means that a GRUB boot menu will be generated, but GRUB itself will not actually be installed. We use UEFI.
        useOSProber = false; # Do not detect other operating systems.
        efiSupport = true;
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
    };
    # ===========================================================================

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    # EnAble all sysrq functions (useful to recover from some issues):
    # Documentation: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
    kernel.sysctl."kernel.sysrq" = 1; # NixOS default: 16 (only the sync command)

    extraModulePackages = [ ];

    kernelParams = [
    ];

    supportedFilesystems = [ "zfs" ];
    zfs.allowHibernation = true;
    zfs.forceImportRoot = false;

    ### Temp Files ==============================================================
    tmp.useTmpfs = false;
    tmp.cleanOnBoot = true;
    # ===========================================================================
  };

  # For zfs support.
  networking.hostId = "28099f57";
}
