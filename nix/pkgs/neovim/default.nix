# Ref: https://github.com/Mic92/dotfiles/blob/7599d40986bc679075bf87539385254d770d8f12/home-manager/modules/neovim/nvim-standalone.nix#L4
{
  lib,
  pkgs,
  nvim-unwrapped ? pkgs.neovim-unwrapped,
  name ? "nvim",
  ...
}:
let
  nvimDrv = pkgs.wrapNeovimUnstable nvim-unwrapped (
    pkgs.neovimUtils.makeNeovimConfig {
      wrapRc = false;
      withRuby = false;
    }
  );

  # Build all treesitter parsers.
  nvim-treesitter-parsers =
    let
      grammars = lib.filterAttrs (
        n: _: lib.hasPrefix "tree-sitter-" n
      ) pkgs.vimPlugins.nvim-treesitter.builtGrammars;
    in
    pkgs.runCommand "nvim-treesitter-parsers" { } ''
      mkdir -p $out/lib/nvim-treesitter-grammars
      ${lib.concatMapStringsSep "\n" (name: ''
        ln -s ${grammars.${name}}/parser \
          $out/lib/nvim-treesitter-grammars/${lib.removePrefix "tree-sitter-" name}.so
      '') (builtins.attrNames grammars)}
    '';

  # Script to use in the nvim-treesitter lua plugin to install parsers.
  nvim-treesitter-install =
    (pkgs.writeShellScriptBin "nvim-treesitter-install" ''
      set -euo pipefail nullglob
      echo "Installing parsers from '${nvim-treesitter-parsers}' into '$(pwd)/parser'"

      mkdir -p parser && rm -rf parser/*.so || {
        echo "Could not remove parser directory."
        exit 1
      }

      ln -s ${nvim-treesitter-parsers}/lib/nvim-treesitter-grammars/*.so parser || {
        echo "Could not symlink parsers."
        exit 1
      }
    '').overrideAttrs
      {
        passthru.rev = pkgs.vimPlugins.nvim-treesitter.src.rev;
      };

  # Define Neovim launch scripts.
  nvim = pkgs.callPackage (import ./nvim-standalone.nix) {
    inherit name;
    nvim = nvimDrv;
    inherit nvim-treesitter-install;
  };
in
{
  nvim-unwrapped = nvimDrv;
  inherit nvim;
  inherit nvim-treesitter-install;
  inherit nvim-treesitter-parsers;
}
