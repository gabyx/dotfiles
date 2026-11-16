{
  config,
  pkgsUnstable,
  ...
}:
{
  ### Virtualisation ==========================================================
  users.users.${config.settings.user.name}.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  # Libvirtd ===============================
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = true;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
  users.groups.libvirtd.members = [ config.settings.user.name ];
  # ========================================

  environment.systemPackages = [
    pkgsUnstable.virt-manager
    pkgsUnstable.virt-viewer
  ];

  # Virtualbox
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # ===========================================================================
}
