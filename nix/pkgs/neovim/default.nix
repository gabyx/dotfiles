# Ref: https://github.com/Mic92/dotfiles/blob/7599d40986bc679075bf87539385254d770d8f12/home-manager/modules/neovim/nvim-standalone.nix#L4
{
  lib,
  pkgs,

  # The nvim to wrap.
  nvim-unwrapped ? pkgs.neovim-unwrapped,

  # The name of the executable and config folder.
  name ? "nvim",
  ...
}:
let
  nvimDrv = pkgs.wrapNeovimUnstable nvim-unwrapped {
    wrapRc = false;
    withRuby = false;
    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };

  # Define Neovim launch scripts.
  nvim = pkgs.callPackage (import ./nvim-standalone.nix) {
    inherit name;
    nvim = nvimDrv;
  };
in
{
  nvim-unwrapped = nvimDrv;
  inherit nvim;
}
