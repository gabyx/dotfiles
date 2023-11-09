{ inputs, system, pkgs, pkgs-unstable, ... }:

with inputs;

{
  # The NixOs for the virtual machine.
  vm = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit system pkgs-unstable; };
    modules = [
      ./vm/configuration.nix
    ];
  };

  # The NixOs running on bare metal.
  desktop = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit system pkgs-unstable; };
    modules = [
      ./desktop/configuration.nix
    ];
  };
}
