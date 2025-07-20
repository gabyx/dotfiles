{
  description = "My NixOS Configurations";

  nixConfig = {
    substituters = [
      # Replace the official cache with a mirror located in China
      # Add here some other mirror if needed.
      "https://cache.nixos.org/"
    ];
    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Nixpkgs (stuff for the system.)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Nixpkgs (unstable stuff for certain packages.)
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Index the nix-store.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Some Hardware Modules.
    hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    # Home-Manager for NixOS.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-Alien
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Format the repo with nix-treefmt.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Terminal `wezterm` nightly
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Githooks.
    githooks = {
      url = "github:gabyx/githooks?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Neovim Nightly.
    nvim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nvim-nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Age Encryption Tool for NixOS.
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Tool to regulate CPU power.
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      overlays = import ./overlays { inherit inputs; };

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;

      importNixpkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            overlays.additions
            overlays.unstable
            overlays.modifications
          ];
        };
    in
    {
      # Your custom packages: Accessible through 'nix build', 'nix shell', etc.
      packages = forAllSystems (system: (importNixpkgs system).additions);

      # Formatter for all files.
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
          treefmt = treefmtEval.config.build.wrapper;
        in
        treefmt
      );

      # Your custom packages and modifications, exported as overlays
      inherit overlays;

      # Reusable NixOS modules you might want to export.
      nixosModules = import ./modules/nixos;

      # Reusable home-manager modules you might want to export.
      homeManagerModules = import ./modules/home;

      # NixOS configurations: Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = import ./nixos { inherit inputs outputs; };
    };
}
