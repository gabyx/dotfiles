# This file defines overlays
{ inputs, ... }:
{
  # Overlays are very useful to overwrite a package globaly which then gets used transitively.
  # So overlays should only be used when a package must be overwritten for all
  # packages which might need to use this derivation override as well.
  #
  # [Read more here](docs/pass-inputs-to-modules.md) and
  # [here](https://nix-community.github.io/home-manager/options.xhtml#opt-nixpkgs.overlays).

  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # We need a patched version with some dependencies (for the systemd service).
    vdirsyncer = prev.callPackage ../pkgs/vdirsyncer { vdirsyncer = prev.vdirsyncer; };

    # We need latest calendar CLI on `main` with `--json` support.
    khal = prev.callPackage ../pkgs/khal { };
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
