{ inputs, lib, ... }:
{
  perSystem =
    { pkgsUnstable, system, ... }:
    let
      nvimBuilds = import ./neovim {
        inherit lib;
        pkgs = pkgsUnstable;
        name = "nvim-new";
      };

      nvimBuildsPinned = import ./neovim {
        inherit lib;
        pkgs = inputs.nvim-pinned.legacyPackages.${system};
        name = "nvim";
      };

      nvimBuildsNightly = import ./neovim {
        inherit lib;
        pkgs = pkgsUnstable;
        name = "nvim-nightly";
        nvim-unwrapped = inputs.nvim-nightly.packages.${system}.neovim;
      };

      # Package which ads a Filesystem Hierarchy Standard environment
      # with `fhs`. Build with `nix build .#fhs`
      # fhs = pkgs.callPackage ./fhs.nix {};

      # Batman Timezone Converter.
      # batz = pkgs.callPackage ./batz { };

      gabyx = import ./scripts { inherit pkgsUnstable; };

      neural-amp-modeler-lv2 = pkgsUnstable.callPackage ./neural-amp-modeler-lv2 { };
    in
    {
      packages = {
        nvim = nvimBuildsPinned.nvim;
        nvim-new = nvimBuilds.nvim;
        inherit (nvimBuildsPinned) nvim-treesitter-install nvim-treesitter-parsers;

        nvim-nightly = nvimBuildsNightly.nvim;

        inherit neural-amp-modeler-lv2;
      }
      // gabyx;
    };
}
