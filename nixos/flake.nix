{
  description = "My NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };
  
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
      	inherit system;
	config = {
	  allowUnfree = true;
	};
      };
    in
    {
      nixosConfigurations = {
	# The NixOs for the virtual machine.
	vm = nixpkgs.lib.nixosSystem {
	  specialArgs = { inherit system; };
	  modules = [
	    ./configuration-vm.nix
	  ];
	};
	
	# The NixOs running on bare metal.
	desktop = nixpkgs.lib.nixosSystem {
	  specialArgs = { inherit system; };
	  modules = [
	    ./configuration-desktop.nix
	  ];
	};
      };
    };
}
