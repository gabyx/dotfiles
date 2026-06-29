# TODO: Remove these derivations once nvf settles.
{ inputs, lib, ... }:
{
  perSystem =
    { pkgsUnstable, system, ... }:
    let
      # Here we build the neovim wrapper
      # with `nvim-treesitter`.

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
        nvim = nvimPinned.nvim;
        nvim-nightly = nvimPinnedNightly.nvim;
      };
    };
}
