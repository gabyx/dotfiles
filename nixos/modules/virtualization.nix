{ config, pkgs, ... }:

{
  ### Virtualisation ==========================================================
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  # boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ "kvm-amd" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = { 
      ovmf.enable = true;
      runAsRoot = true;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  
  # Virtualbox
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # ===========================================================================
}
