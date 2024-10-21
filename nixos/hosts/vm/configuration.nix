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
let
  modules = inputs.self + /nixos/modules;

  pkgsStable = import inputs.nixpkgsStable {
    system = pkgs.system;
    config = {
      allowUnfree = true;
    };
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./boot.nix

    # Load the NixOS age encryption module to encrypt/decrypt
    # secrets with this NixOS configuration
    inputs.agenix.nixosModules.default

    # Include all other specifications.
    (outputs.nixosModules.windowing { inherit config pkgs pkgsStable; })
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

    outputs.nixosModules.virtualization

    outputs.nixosModules.packages
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
        pkgsStable
        ;
    })
  ];

  ### NixOS Release Settings===================================================
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.stateVersion = "23.05";
  # ===========================================================================
}
