{ ... }:
{
  # Enable all SYSRQ functions (useful to recover from some issues):
  # Documentation: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
  boot.kernel.sysctl."kernel.sysrq" = 1; # NixOS default: 16 (only the sync command)
}
