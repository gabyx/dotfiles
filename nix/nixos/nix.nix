{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ ./nix-cache.nix ];

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = [
        "auto-allocate-uids"
        "cgroups"

        "fetch-closure"
        "fetch-tree"

        "nix-command"
        "flakes"
        "impure-derivations"
        "pipe-operators"

        "ca-derivations"
        "dynamic-derivations"
        "recursive-nix"
      ];

      use-xdg-base-directories = true;

      lint-url-literals = "fatal";
      # lint-short-path-literals = "warn";
      # lint-absolute-path-literals = "warn";

      warn-dirty = false;
      max-jobs = "auto"; # Use all available CPU cores for building packages.

      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      # Avoid unwanted garbage collection when using nix-direnv.
      keep-outputs = true;
      keep-derivations = true;

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    # Garbage collector.
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 180d";
    };
  };
}
