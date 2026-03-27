{
  config,
  ...
}:
let
  # Use script: `scripts/compute-swap-offset.nix`.
  swapConfig = import ./swap-offset.nix;
in
{
  boot = {

    # Bootloader ================================================================
    loader = {
      grub = {
        enable = true;
        device = "nodev"; # The special value nodev means that a GRUB boot menu will be generated, but GRUB itself will not actually be installed. We use UEFI.
        useOSProber = false; # Do not detect other operating systems.
        efiSupport = true;
        enableCryptodisk = true;
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
    # ===========================================================================

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    kernelModules = [
      "kvm"
      "kvm-amd"
    ];
    extraModulePackages = [ ];

    kernelParams = [
      "amdgpu.dpm=0"
      "amdgpu.dcdebugmask=0x10"
      # Hibernation parameters
      "resume=UUID=${builtins.baseNameOf config.fileSystems."/swap".device}"
      "resume_offset=${toString swapConfig.resumeOffset}"
    ];

    supportedFilesystems = [ "zfs" ];
    zfs.allowHibernation = true;
    zfs.forceImportRoot = false;

    ### Temp Files ==============================================================
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
    # ===========================================================================
  };

  # For zfs support.
  networking.hostId = "28099f56";
}
