{
  config,
  pkgs,
  inputs,
  ...
}:
{
  boot = {
    # Your `hardware-configuration.nix` should configure the LUKS device setup.
    # It should not be included here.

    # Enable all sysrq functions (useful to recover from some issues):
    # Documentation: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
    kernel.sysctl."kernel.sysrq" = 1; # NixOS default: 16 (only the sync command)

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
