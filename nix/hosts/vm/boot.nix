{
  config,
  pkgs,
  ...
}:
{
  boot = {
    # Enable all sysrq functions (useful to recover from some issues):
    # Documentation: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
    kernel.sysctl."kernel.sysrq" = 1; # NixOS default: 16 (only the sync command)

    # Bootloader ================================================================
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = false; # Do not detect other operating systems.
        # efiSupport = true;
        # enableCryptodisk = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
    # ===========================================================================

    # Encryption ================================================================
    initrd.secrets = {
      "/crypto_keyfile.bin" = null;
    };
    initrd.luks.devices."luks-b71db585-62d5-4ab7-ac2b-f3a3495561ab".keyFile = "/crypto_keyfile.bin";
    # ===========================================================================

    ### Temp Files ==============================================================
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
    # ===========================================================================
  };
}
