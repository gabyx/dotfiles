{
  self,
  inputs,
  ...
}:
let
  overlays = [ self.overlays.modifications ];

  config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-12.2.3"
      "electron-19.1.9"
    ];

    nvidia.acceptLicense = true;
  };

  stable =
    system:
    import inputs.nixpkgs {
      inherit system overlays config;
    };

  unstable =
    system:
    import inputs.nixpkgs-unstable {
      inherit system overlays config;
    };
in
{

  # Add two library functions.
  flake.lib.importPkgs = stable;
  flake.lib.importPkgsUnstable = unstable;

  perSystem =
    {
      system,
      ...
    }:
    let
      pkgs = stable system;
      pkgsUnstable = unstable system;
    in
    {
      _module.args.pkgs = pkgs;
      _module.args.pkgsUnstable = pkgsUnstable;

      legacyPackages.unstable = pkgsUnstable;
    };
}
