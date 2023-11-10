# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: let
  modules = "../../modules";

  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config = {
      allowUnfree = true;
    };
  };
in {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ./boot.nix
    ./hardware.nix

    # Include all other specifications.
    ./${modules}/windowing.nix
    ./${modules}/display.nix
    ./${modules}/keyboard.nix
    ./${modules}/fonts.nix
    ./${modules}/time.nix
    ./${modules}/environment.nix
    ./${modules}/networking.nix
    ./${modules}/security.nix

    ./${modules}/services.nix

    ./${modules}/sound.nix
    ./${modules}/printing.nix

    ./${modules}/virtualization.nix
    (import ./${modules}/packages.nix {inherit config pkgs pkgs-unstable;})
    ./${modules}/programs.nix

    ./${modules}/user.nix

    ./${modules}/nix.nix
  ];

  nixpkgs = {
    # You can add overlays here.
    overlays = [
      # Add overlays of your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
  };

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
