# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  outputs,
  ...
}:
{
  disabledModules = [
  ];

  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # inputs.self.modules.nixos.example

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.tuxedo-pulse-14-gen3
    inputs.auto-cpufreq.nixosModules.default

    # Load the NixOS age encryption module to encrypt/decrypt
    # secrets with this NixOS configuration
    inputs.agenix.nixosModules.default

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ./cpu.nix
    ./boot.nix
    ./hardware.nix
    ./settings.nix

    # Include all other specifications.
    inputs.self.modules.nixos.windowing
    inputs.self.modules.nixos.display
    inputs.self.modules.nixos.keyboard
    inputs.self.modules.nixos.fonts
    inputs.self.modules.nixos.time
    inputs.self.modules.nixos.environment
    inputs.self.modules.nixos.networking
    inputs.self.modules.nixos.networking-profiles
    inputs.self.modules.nixos.vpn
    inputs.self.modules.nixos.backup
    inputs.self.modules.nixos.secrets
    inputs.self.modules.nixos.security

    inputs.self.modules.nixos.services

    inputs.self.modules.nixos.sound
    inputs.self.modules.nixos.printing

    inputs.self.modules.nixos.containerization
    inputs.self.modules.nixos.virtualization

    inputs.self.modules.nixos.packages
    inputs.self.modules.nixos.programs

    inputs.self.modules.nixos.user

    inputs.self.modules.nixos.nix

    # Load home-manager as a part of the NixOS configuration.
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
