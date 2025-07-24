# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  disabledModules = [
  ];

  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

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

    # Include all other specifications.
    (outputs.nixosModules.windowing { inherit config pkgs; })
    outputs.nixosModules.display
    outputs.nixosModules.keyboard
    outputs.nixosModules.fonts
    outputs.nixosModules.time
    outputs.nixosModules.environment
    outputs.nixosModules.networking
    outputs.nixosModules.security

    outputs.nixosModules.services

    outputs.nixosModules.sound
    outputs.nixosModules.printing

    outputs.nixosModules.containerization
    outputs.nixosModules.virtualization

    (outputs.nixosModules.packages {
      inherit
        config
        pkgs
        inputs
        ;
    })
    outputs.nixosModules.programs

    outputs.nixosModules.user

    outputs.nixosModules.nix

    # Load home-manager as a part of the NixOS configuration.
    inputs.home-manager.nixosModules.home-manager
    (outputs.nixosModules.home-manager {
      inherit
        config
        inputs
        outputs
        ;
    })
  ];

  nixpkgs = {
    # You can add overlays here.
    overlays = [
      # NOTE: We are not eagerly using overlays so far, we pass inputs directly to modules.
      #       Overlays is a recursive mechanism which is only used when a
      #       package needs to be overwritten globally.

      # Add overlays of your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable
    ];
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
