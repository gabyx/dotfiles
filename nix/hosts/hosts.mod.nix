{
  inputs,
  self,
  ...
}:
let
  outputs = self;

  mkSystem =
    system: name:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = outputs.lib.importPkgs system;

      modules = [
        ./${name}/configuration.nix
      ];

      specialArgs = {
        inherit system inputs outputs;
        pkgsUnstable = outputs.lib.importPkgsUnstable system;
      };
    };

  mkImage =
    format: system: name:
    inputs.nixos-generators.nixosGenerate {
      pkgs = outputs.lib.importPkgs system;

      inherit format system;
      modules = [
        ./${name}/configuration.nix
      ];

      specialArgs = {
        inherit system inputs outputs;
        pkgsUnstable = outputs.lib.importPkgsUnstable system;
      };

    };

in
{
  flake.nixosConfigurations = {
    desktop = mkSystem "x86_64-linux" "desktop";
    desktop-music = mkSystem "x86_64-linux" "desktop-music";
    tuxedo = mkSystem "x86_64-linux" "tuxedo-pulse-14";
    vm = mkSystem "x86_64-linux" "vm";
  };

  perSystem =
    { ... }:
    {
      packages.vm-image = mkImage "iso" "x86_64-linux" "vm-iso";
      packages.desktop-image = mkImage "iso" "x86_64-linux" "desktop-iso";
      packages.famhome-image = mkImage "raw-efi" "x86_64-linux" "famhome";
    };
}
