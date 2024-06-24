# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelParams = []; # ["amdgpu.aspm=0"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  # Use the latest kernel for the shutdown problem,
  # that the power turns completely off.
  boot.kernelPackages =
    if (config.boot.zfs.enabled)
    then pkgs.zfs.latestCompatibleLinuxPackages
    else pkgs.linuxPackages_latest;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6fbd4c98-9ca9-4a8a-966f-24491282220b";
    fsType = "btrfs";
    options = ["subvol=root"];
  };

  boot.initrd.luks.devices."enc-physical-vol".device = "/dev/disk/by-uuid/c770819c-1193-4a1e-a94d-3e13dc634a2e";

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/6fbd4c98-9ca9-4a8a-966f-24491282220b";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/6fbd4c98-9ca9-4a8a-966f-24491282220b";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/6fbd4c98-9ca9-4a8a-966f-24491282220b";
    fsType = "btrfs";
    options = ["subvol=persist" "compress=zstd" "noatime"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/6fbd4c98-9ca9-4a8a-966f-24491282220b";
    fsType = "btrfs";
    options = ["subvol=log" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/6fbd4c98-9ca9-4a8a-966f-24491282220b";
    fsType = "btrfs";
    options = ["subvol=swap" "compress=zstd" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1ECB-0D03";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [{device = "/swap/swapfile";}];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0f3u2c2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
