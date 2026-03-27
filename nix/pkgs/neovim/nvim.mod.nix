{ inputs, lib, ... }:
{
  perSystem =
    { pkgsUnstable, system, ... }:
    let
      # Here we build the neovim wrapper
      # with `nvim-treesitter`.

      nvimNew = import ./default.nix {
        inherit lib;
        name = "nvim-new";
        pkgs = pkgsUnstable;
      };

      pkgsPlugins = inputs.nvim-astronvim.legacyPackages.${system};

      nvimPinned = import ./default.nix {
        inherit lib;
        name = "nvim";
        pkgs = pkgsUnstable;

        inherit pkgsPlugins;
        nvim-unwrapped = pkgsPlugins.neovim-unwrapped;
      };

      nvimPinnedNightly = import ./default.nix {
        inherit lib;
        name = "nvim-nightly";
        pkgs = pkgsUnstable;

        inherit pkgsPlugins;
        nvim-unwrapped = inputs.nvim-nightly.packages.${system}.neovim;
      };
    in
    {
      packages = {
        # Pinned neovims.
        nvim = nvimPinned.nvim;
        inherit (nvimPinned) nvim-treesitter-install nvim-treesitter-parsers;
        nvim-nightly = nvimPinnedNightly.nvim;

        # Neovim with latest treesitter.
        nvim-new = nvimNew.nvim;
      };
    };
}
