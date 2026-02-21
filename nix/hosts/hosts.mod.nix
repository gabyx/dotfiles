{
  inputs,
  withSystem,
  self,
  ...
}:
let
  outputs = self;

  # Creates a nixoConfiguration or an image.
  mk =
    name:
    args@{ system, ... }:
    create:
    # Wrap flake-parts arguments into...
    withSystem system (
      { config, inputs', ... }:
      create (
        args
        // {
          # Set packages.
          pkgs = outputs.lib.importPkgs system;

          # Import all modules.
          modules = [
            ./${name}/configuration.nix
          ];

          # Set special arguments to the modules.
          specialArgs = {
            inherit
              system
              inputs
              outputs
              ;

            # Flake parts inputs.
            inherit inputs';
            packages = config.packages;

            pkgsUnstable = outputs.lib.importPkgsUnstable system;
          };
        }
      )
    );

  mkSystem = name: args: mk name args inputs.nixpkgs.lib.nixosSystem;
  mkImage = name: args: mk name args inputs.nixos-generators.nixosGenerate;

in
{
  flake.nixosConfigurations = {
    desktop = mkSystem "desktop" {
      system = "x86_64-linux";
    };
    desktop-music = mkSystem "desktop-music" {
      system = "x86_64-linux";
    };
    tuxedo = mkSystem "tuxedo-pulse-14" {
      system = "x86_64-linux";
    };
    vm = mkSystem "vm" {
      system = "x86_64-linux";
    };
  };

  perSystem =
    { system, ... }:
    {
      packages.vm-image = mkImage "vm-iso" {
        inherit system;
        format = "iso";
      };
      packages.desktop-image = mkImage "desktop-iso" {
        inherit system;
        format = "iso";
      };
      packages.famhome-image = mkImage "famhome" {
        inherit system;
        format = "raw-efi";
      };
    };
}
