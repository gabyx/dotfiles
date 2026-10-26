{
  lib,
  self,
  inputs,
  ...
}:
let
  overlays = [ self.overlays.modifications ];

  config = {
    allowUnfree = true;

    # permittedInsecurePackages = [
    #   "electron-39.8.10"
    # ];

    nvidia.acceptLicense = true;
  };

  mkMultiverse =
    system:
    inputs.multiverse.lib.mkMultiverse {
      inherit system overlays config;
    };

  stable =
    system:
    import inputs.nixpkgs {
      inherit system overlays config;
    };
in
{
  flake.lib.mkMultivere = mkMultiverse;

  perSystem =
    {
      system,
      ...
    }:
    let
      pkgs = stable system;
      mvs = mkMultiverse system;

      # Use a 7 days behind a pinned unstable for security reasons.
      # To update run: `nix flake update multiverse` and `direnv reload`
      # and check the assert below and take the unstable tip commit.
      pkgsUnstableCooldown = mvs.daysBehind "3ec636362e1816bc2f0888fa0fa2c69f1bc9e504" 7;

      pkgsUnstable =
        assert lib.assertMsg (pkgsUnstableCooldown.multiverse.rev == inputs.nixpkgs-unstable.rev) ''
          Input 'nixpkgs' must be
          aligned with cooldown 7 days behind: "${pkgsUnstableCooldown.multiverse.rev}".
          NixOS unstable tip: '${mvs.tip.multiverse.rev}'.
        '';
        lib.trace "NixOS unstable tip: '${mvs.tip.multiverse.rev}'." pkgsUnstableCooldown;
    in
    {
      _module.args.pkgs = pkgs;
      _module.args.mvs = mvs;

      _module.args.mkNixOSSystem = inputs.nixpkgs.lib.nixosSystem; # Pin the nixosSystem to the imported pkgs.

      _module.args.pkgsUnstable = pkgsUnstable;
      legacyPackages.unstable = pkgsUnstable;
    };
}
