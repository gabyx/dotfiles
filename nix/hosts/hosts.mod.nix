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
        inherit inputs outputs;
        pkgsUnstable = outputs.lib.importPkgsUnstable system;
      };
    };
in
{
  flake.nixosConfigurations = {
    desktop = mkSystem "x86_64-linux" "desktop";
    tuxedo = mkSystem "x86_64-linux" "tuxedo-pulse-14";
    vm = mkSystem "x86_64-linux" "vm";
  };
}
