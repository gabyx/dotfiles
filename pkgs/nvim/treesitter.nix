{ pkgs, lib, ... }:
let
  nvim-treesitter-plugins =
    let
      grammars = lib.filterAttrs (
        n: _: lib.hasPrefix "tree-sitter-" n
      ) pkgs.vimPlugins.nvim-treesitter.builtGrammars;
    in
    pkgs.runCommand "nvim-treesitter-plugins" { } ''
      mkdir -p $out/lib/nvim-treesitter-gammars
      ${lib.concatMapStringsSep "\n" (name: ''
        ln -s ${grammars.${name}}/parser $out/lib/nvim-treesitter-gammars/${lib.removePrefix "tree-sitter-" name}.so
      '') (builtins.attrNames grammars)}
    '';

  nvim-install-treesitter =
    (pkgs.writeShellScriptBin "nvim-install-treesitter" ''
      set -euo pipefail nullglob
      mkdir -p parser
      rm -rf parser/*.so

      # prefer home-manager version if it exists, because it doesn't get stale links.
      if [ -d $HOME/.nix-profile/lib/nvim-treesitter-plugins ]; then
        ln -s $HOME/.nix-profile/lib/nvim-treesitter-plugins/lib/nvim-treesitter-gammars/*.so parser
      else
        ln -s ${nvim-treesitter-plugins}/lib/nvim-treesitter-gammars/*.so parser
      fi
    '').overrideAttrs
      (_: {
        passthru.rev = pkgs.vimPlugins.nvim-treesitter.src.rev;
      });
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
