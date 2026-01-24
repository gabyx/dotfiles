{
  pkgs,
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
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    # Hibernation parameters
    # TODO: Does not work yet, it hibernated but cannot resume...
    # boot.resumeDevice = config.fileSystems."/swap".device;
    kernelParams = [
      # Hibernation parameters
      # "resume=UUID=${builtins.baseNameOf config.fileSystems."/swap".device}"
      # "resume_offset=${toString swapConfig.resumeOffset}"

      # GPU Freezes:
      # https://www.reddit.com/r/tuxedocomputers/comments/1jjzye7/amdgpu_especially_780m_is_not_ready/
      # See: https://codeberg.org/balint/nixos-configs/src/branch/main/hosts/tuxedo/conf.nix
      "amdgpu.dpm=0"
      "amdgpu.dcdebugmask=0x10"
      # "amdgpu.aspm=0"
      # Kernels: 6.6.87 had no problem, 6.12.31 probably started the problems.
    ];

    kernelModules = [
      "kvm"
      "kvm-amd"
    ];
    extraModulePackages = [ ];

    # TODO: Check if this kernel works without running into
    # amdgpu freezes.
    kernelPackages = pkgs.linuxPackages_xanmod;

    supportedFilesystems = [ "zfs" ];
    zfs.allowHibernation = true;
    zfs.forceImportRoot = false;

    ### Temp Files ==============================================================
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
    # ===========================================================================
  };

  # For zfs support.
  networking.hostId = "06c1ee33";
}
