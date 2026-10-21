{
  inputs,
  withSystem,
  self,
  ...
}:
let

  mkSystem =
    name:
    { system, ... }:
    # Wrap flake-parts arguments into using `withSystem`...
    withSystem system (
      {
        inputs',
        self',
        pkgs,
        pkgsUnstable,
        mvs,
        wrappersLib,
        mkNixOSSystem,
        ...
      }:
      mkNixOSSystem {
        modules = [
          {
            nixpkgs.pkgs = pkgs;
            nixpkgs.hostPlatform = system;
          }
          ./${name}/configuration.nix
        ];

        # Set special arguments to the modules.
        specialArgs = {
          inherit
            system
            inputs
            self
            ;

          # Flake parts inputs (already system scoped).
          inherit inputs';
          inherit self';
          inherit (self') packages;
          inherit pkgsUnstable;
          inherit mvs;
          inherit wrappersLib;
        };
      }
    );

  desktop = mkSystem "desktop" {
    system = "x86_64-linux";
  };
  tuxedo = mkSystem "tuxedo-pulse-14" {
    system = "x86_64-linux";
  };

  desktop-image = mkSystem "desktop-image" {
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
      desktop-image
      tuxedo
      vm
      ;
  };

  perSystem =
    { system, ... }:
    {
      packages.desktop-iso = desktop-image.config.system.build.images.iso;

      packages.famhome-image =
        (mkSystem "famhome" {
          inherit system;
        }).config.build.images.raw-efi;
    };
}
