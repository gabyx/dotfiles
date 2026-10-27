{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = [ pkgs.sbctl ];

  boot = {
    # Bootloader ================================================================
    loader = {
      systemd-boot = {
        # Lanzaboote replaces the systemd-boot module, which must stay disabled.
        enable = lib.mkForce false;
        configurationLimit = 30;
      };

      efi = {
        canTouchEfiVariables = true;
      };

      limine = {
        enable = true;
        maxGenerations = 30;
        secureBoot.enable = true;
      };
    };

    lanzaboote = {
      enable = false; # Using limine now.
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 30;
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
    zfs.forceImportRoot = false;

    ### Temp Files ==============================================================
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
    # ===========================================================================
  };

  # For zfs support.
  networking.hostId = "06c1ee33";
}
