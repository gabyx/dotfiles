{
  config,
  lib,
  pkgs,
  outputs,
  ...
}: {
  ### Virtualisation ==========================================================
  users.users.${config.settings.user.name}.extraGroups = [
    "docker"
    "podman"
    "libvirtd"
  ];

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

  # Docker =================================
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    rootless = {
      enable = false;
      setSocketVariable = true;
    };

    # Auto prune podman resources.
    autoPrune = {
      dates = "weekly";
      flags = ["--external"];
    };
  };
  # =======================================

  # Podman ================================
  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    # dockerCompat = true;
    # dockerSocket = {
    #   enable = true;
    # };

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;

    # Auto prune podman resources.
    autoPrune = {
      dates = "weekly";
      flags = ["--external"];
    };
  };

  virtualisation.containers = {
    # Podman already enables this, I guess.
    enable = true;

    # storage.settings = {
    #   storage = {
    #     driver = "overlay";
    #     graphroot = "/var/lib/containers/storage";
    #     runroot = "/run/containers/storage";
    #     options.overlay = {
    #       mount_program = lib.getExe pkgs.fuse-overlayfs;
    #       mountopt = "nodev,fsync=0";
    #     };
    #   };
    # };
  };
  # =======================================

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

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "-";
      item = "nproc";
      value = "1048576";
    }
  ];

  # Virtualbox
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;

  # Packages
  environment.systemPackages = with pkgs; [
    kubectl
    kind # Simple kubernetes for local development.
    k9s # Kubernetes management CLI tool
    podman-compose

    podman-compose

    # Other virtualisation stuff.
    # virt-manager
    # libguestfs # Needed to virt-sparsify qcow2 files
    # libvirt
    # spice # For automatic window resize if this conf is used as OS in VM
    # spice-vdagent
  ];
  # ===========================================================================
}
