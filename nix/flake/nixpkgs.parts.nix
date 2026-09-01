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

    permittedInsecurePackages = [
      "electron-39.8.10"
    ];

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

      # Use a 7 days behind unstable for security reasons.
      pkgsUnstableCooldown = mvs.daysBehind "tip" 7;
      pkgsUnstable =
        assert lib.assertMsg (pkgsUnstableCooldown.multiverse.rev == inputs.nixpkgs-unstable.rev)
          "Input 'nixpkgs-unstable' must be aligned with cooldown 7 days behind '${pkgsUnstableCooldown.multiverse.rev}'.";
        pkgsUnstableCooldown;
    in
    {
      _module.args.pkgs = pkgs;
      _module.args.mvs = mvs;

      _module.args.mkNixOSSystem = inputs.nixpkgs.lib.nixosSystem; # Pin the nixosSystem to the imported pkgs.

      _module.args.pkgsUnstable = pkgsUnstable;
      legacyPackages.unstable = pkgsUnstable;
    };
}
