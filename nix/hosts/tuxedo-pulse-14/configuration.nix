# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  ...
}:
{
  disabledModules = [
  ];

  imports = [
    inputs.hardware.nixosModules.tuxedo-pulse-14-gen3
    inputs.auto-cpufreq.nixosModules.default
    inputs.agenix.nixosModules.default

    ./hardware.nix
    ./filesystem.nix
    ./cpu.nix
    ./boot.nix

    inputs.self.nixosModules.settings
    inputs.self.nixosModules.backup
    inputs.self.nixosModules.bluetooth
    inputs.self.nixosModules.containerization
    inputs.self.nixosModules.display
    inputs.self.nixosModules.environment
    inputs.self.nixosModules.fonts
    inputs.self.nixosModules.kernel
    inputs.self.nixosModules.keyboard
    inputs.self.nixosModules.networking
    inputs.self.nixosModules.networking-profiles
    inputs.self.nixosModules.nix
    inputs.self.nixosModules.packages
    inputs.self.nixosModules.printing
    inputs.self.nixosModules.programs
    inputs.self.nixosModules.secrets
    inputs.self.nixosModules.security
    inputs.self.nixosModules.services
    inputs.self.nixosModules.sound
    inputs.self.nixosModules.system
    inputs.self.nixosModules.time
    inputs.self.nixosModules.user
    inputs.self.nixosModules.virtualization
    inputs.self.nixosModules.windowing
    inputs.self.nixosModules.yubikey

    inputs.self.nixoshomeModules

    ./settings.nix
    ../common/yubikey.nix
    ../common/notempfs.nix
  ];

  specialisation = {
    # Dont use tempfs (ram) for the /tmp.
    # Sometimes useful when building large stuff which exhausts memory.
    notempfs = {
      inheritParentConfig = true;
      configuration = {
        boot.tmp.useTmpfs = lib.mkForce false;
      };
    };
  };

  ### NixOS Release Settings===================================================
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
  # ===========================================================================
}
