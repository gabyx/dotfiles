{
  description = "My NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    # Tracks nixos/nixpkgs-channels unstable branch.
    #
    # Try to pull new/updated packages from 'unstable' whenever possible, as
    # these will likely have cached results from the last successful Hydra
    # jobset.
    nixpkgs-unstable.url = "github:nixos/nixpkgs-channels/nixos-unstable";
    # Tracks nixos/nixpkgs main branch.
    #
    # Only pull from 'trunk' when channels are blocked by a Hydra jobset
    # failure or the 'unstable' channel has not otherwise updated recently for
    # some other reason.
    trunk.url = "github:nixos/nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

    in
    {
      nixosConfigurations =
        import ./nixos/hosts/hosts.nix { inherit inputs system pkgs pkgs-unstable; };
    };
}
