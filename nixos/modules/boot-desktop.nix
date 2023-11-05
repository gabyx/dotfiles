{ config, pkgs, ... }:

{
  boot = {
    # Your `hardware-configuration.nix` should configure the LUKS device setup.
    # It should not be included here.

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


    ### Temp Files ==============================================================
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
    # ===========================================================================
  };
}
