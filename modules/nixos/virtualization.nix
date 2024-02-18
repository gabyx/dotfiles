{
  config,
  pkgs,
  ...
}: {
  ### Virtualisation ==========================================================

  # Libvirtd ===============================
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  # boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = ["kvm-amd"];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.enable = true;
      runAsRoot = true;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # ========================================

  users.users.${config.settings.user.name}.extraGroups = [
    # "docker"
    "podman"
    "libvirtd"
  ];

  # Docker
  # virtualisation.docker = {
  #   enable = true;
  #   enableOnBoot = true;
  # };

  # Podman
  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;
    dockerSocket = {
      enable = true;
    };

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;

    # Auto prune podman resources.
    autoPrune = {
      dates = "weekly";
      flags = ["--external"];
    };
  };

  # Extent the user `uid/gid` ranges to make podman work better.
  # This is for using https://gitlab.com/qontainers/pipglr
  users.extraUsers.${config.settings.user.name} = {
    subUidRanges = [
      {
        startUid = 100000;
        count = 65539;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65539;
      }
    ];
  };

  # Virtualbox
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # ===========================================================================
}
