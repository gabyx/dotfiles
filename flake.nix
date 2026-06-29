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

  # We use flake-parts to assemble all flake outputs.
  # This gives nicer modularity. All `.mod` files are
  # `flake-parts` files.
  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;

      tree =
        inputs.import-tree # -
          (i: i.map (x: lib.info "Importing: '${x}'" x))
          (i: i.filter (lib.hasInfix ".mod."))
          (
            i:
            i [
              ./nix
              ./tools/nix
            ]
          );
    in
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    } tree;

  inputs = {
    self = {
      submodules = true;
      # lfs = true;
    };

    import-tree = {
      url = "github:vic/import-tree";
    };

    systems = {
      # Using `nix-systems` flake specification.
      url = "path:./nix/flake/systems.nix";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # Nixpkgs (stuff for the system.)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

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
      url = "github:nix-community/home-manager/release-26.05";
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
    };

    # Pinning treesitter for Astronvim.
    nvim-astronvim = {
      url = "github:NixOS/nixpkgs?rev=b3da656039dc7a6240f27b2ef8cc6a3ef3bccae7";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix?ref=v2.1.195";
    };
    agent-sandbox = {
      url = "github:archie-judd/agent-sandbox.nix";
    };

    # Pinned Nixpkgs for nvim.
    # =========================================================================
    # TODO: Make own flake for Nvim.
    nvim-nixpkgs = {
      # Ref to : nixpkgs/nixos-unstable from `nixpkgs-unstable`
      url = "github:nixos/nixpkgs?ref=567a49d1913ce81ac6e9582e3553dd90a955875f";
    };
    nvim-nvf = {
      url = "github:gabyx/nvf?ref=feat/add-app-name";
      inputs.nixpkgs.follows = "nvim-nixpkgs";
    };
    # Neovim Nightly.
    nvim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    # =========================================================================

    nixpkgs-anydesk = {
      url = "github:FraioVeio/nixpkgs/anydesk/fix-update-script";
    };

    # Instant direnv loading.
    direnv-instant = {
      url = "github:Mic92/direnv-instant";
    };

    # Music stuff.
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Flatpak stuff.
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    };

    jail-nix = {
      url = "sourcehut:~alexdavid/jail.nix?ref=beta";
    };

    nixfmt-rs = {
      url = "github:Mic92/nixfmt-rs";
    };

    # Age Encryption Tool for NixOS.
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Declarative Disk partitioning for VMs.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tool to regulate CPU power.
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
}
