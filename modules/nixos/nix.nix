{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:
{
  ### Nix Specific Settings ===================================================
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;

      # Add your own username to the trusted list
      trusted-users = [ "nixos" ];
    };

    # Garbage collector
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 60d";
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-12.2.3"
        "electron-19.1.9"
      ];
    };
  };
  # ===========================================================================
}
