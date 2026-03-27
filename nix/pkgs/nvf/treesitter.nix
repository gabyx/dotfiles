{ pkgs, lib, ... }:
let
in
{
  vim.treesitter = {
    enable = true;
    # Add all built grammars.
    grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
    addDefaultGrammars = true;

    context = {
      enable = true;
      multilineThreshold = 10;
    };

    autotagHtml = true;

    highlight = {
      enable = true;
      additionalVimRegexHighlighting = false;
    };

    indent.enable = true;
    incrementalSelection.enable = true;

    mappings = {
      incrementalSelection = {
        init = "<CR>";
        # scope_incremental = "<S>";
        incrementByNode = "<CR>";
        decrementByNode = "<BS>";
      };
    };
  };
}
