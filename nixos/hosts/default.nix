{
  inputs,
  outputs,
  ...
}:
with inputs; {
  # The NixOs for the virtual machine.
  vm = nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs outputs;};
    modules = [
      ./vm/configuration.nix
    ];
  };

  # The NixOs running on bare metal.
  desktop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs outputs;};
    modules = [
      ./desktop/configuration.nix
    ];
  };
}
