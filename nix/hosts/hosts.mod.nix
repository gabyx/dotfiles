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

  mkIso =
    system: name:
    inputs.nixos-generators.nixosGenerate {
      pkgs = outputs.lib.importPkgs system;

      inherit system;
      modules = [
        ./${name}/configuration.nix
      ];

      specialArgs = {
        inherit system inputs outputs;
        pkgsUnstable = outputs.lib.importPkgsUnstable system;
      };

      format = "iso";
    };

in
{
  flake.nixosConfigurations = {
    desktop = mkSystem "x86_64-linux" "desktop";
    desktop-steam = mkSystem "x86_64-linux" "desktop-steam";
    desktop-music = mkSystem "x86_64-linux" "desktop-music";
    tuxedo = mkSystem "x86_64-linux" "tuxedo-pulse-14";
    vm = mkSystem "x86_64-linux" "vm";
  };

  perSystem =
    { ... }:
    {
      packages.vm-iso = mkIso "x86_64-linux" "vm-iso";
      packages.desktop-iso = mkIso "x86_64-linux" "desktop-iso";
    };
}
