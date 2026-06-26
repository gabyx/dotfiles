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
    # Wrap flake-parts arguments into using `withSystem`...
    withSystem system (
      {
        config,
        inputs',
        ...
      }:
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

            # Flake parts inputs (already system scoped).
            inherit inputs';
            packages = config.packages;

            pkgsUnstable = outputs.lib.importPkgsUnstable system;
          };
        }
      )
    );

  mkSystem = name: args: mk name args inputs.nixpkgs.lib.nixosSystem;

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
in
{
  flake.nixosConfigurations = {
    inherit
      desktop
      desktop-music
      tuxedo
      vm
      ;
  };

  perSystem =
    { system, ... }:
    {
      packages.vm-image = vm.config.system.build.images.iso;
      packages.desktop-image = desktop.config.system.build.images.iso;

      packages.famhome-image =
        (mkSystem "famhome" {
          inherit system;
        }).config.build.images.raw-efi;
    };
}
