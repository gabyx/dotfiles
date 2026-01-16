{
  ...
}:
{
  boot = {
    # Enable all SYSRQ functions (useful to recover from some issues):
    # Documentation: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
    kernel.sysctl."kernel.sysrq" = 1; # NixOS default: 16 (only the sync command)

    ### Temp Files ==============================================================
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
    # ===========================================================================
  };

  services.qemuGuest.enable = true;
}
