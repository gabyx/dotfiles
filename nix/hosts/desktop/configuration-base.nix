# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.agenix.nixosModules.default

    ./hardware-configuration.nix
    ./cpu.nix
    ./boot.nix
    ./hardware.nix

    inputs.self.modules.nixos.backup
    inputs.self.modules.nixos.containerization
    inputs.self.modules.nixos.display
    inputs.self.modules.nixos.environment
    inputs.self.modules.nixos.flatpak
    inputs.self.modules.nixos.fonts
    inputs.self.modules.nixos.kernel
    inputs.self.modules.nixos.keyboard
    inputs.self.modules.nixos.networking
    inputs.self.modules.nixos.nix
    inputs.self.modules.nixos.packages
    inputs.self.modules.nixos.printing
    inputs.self.modules.nixos.programs
    inputs.self.modules.nixos.security
    inputs.self.modules.nixos.services
    inputs.self.modules.nixos.sound
    inputs.self.modules.nixos.time
    inputs.self.modules.nixos.user
    inputs.self.modules.nixos.virtualization
    inputs.self.modules.nixos.windowing
    inputs.self.modules.nixos.yubikey

    inputs.self.modules.nixos.home-manager
  ];

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
