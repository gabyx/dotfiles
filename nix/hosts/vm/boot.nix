{
  ...
}:
{
  boot = {
    # Enable all SYSRQ functions (useful to recover from some issues):
    # Documentation: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
    kernel.sysctl."kernel.sysrq" = 1; # NixOS default: 16 (only the sync command)

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
  };

}
