# This file defines overlays
{inputs, ...}: {
  # NOTE: we are not using these overlays, they are here for reference only.
  # Why: Passing inputs to modules can be done in different ways, best is to not use
  # overlays, but just using plain old functions.
  # [Read more here](docs/pass-inputs-to-modules.md).

  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stablePackages = final: _prev: {
    stable = import inputs.nixpkgsStable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
