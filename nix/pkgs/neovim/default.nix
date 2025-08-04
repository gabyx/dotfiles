{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  nvimDrv = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (
    pkgs.neovimUtils.makeNeovimConfig {
      wrapRc = false;
      withRuby = false;
    }
  );

  nvimNightlyDrv = pkgs.wrapNeovimUnstable inputs.nvim-nightly.packages.${pkgs.system}.neovim (
    pkgs.neovimUtils.makeNeovimConfig {
      wrapRc = false;
      withRuby = false;
    }
  );

  # Define Neovim launch scripts.
  nvim = pkgs.callPackage (import ./nvim-standalone.nix) {
    name = "nvim";
    nvim = nvimDrv;
    inherit nvim-treesitter-install;
  };

  nvim-nightly = pkgs.callPackage (import ./nvim-standalone.nix) {
    name = "nvim-nightly";
    nvim = nvimNightlyDrv;
    inherit nvim-treesitter-install;
  };

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
      mkdir -p parser
      rm -rf parser/*.so

      # prefer home-manager version if it exists, because it doesn't get stale links.
      if [ -d $HOME/.nix-profile/lib/nvim-treesitter-parsers ]; then
        ln -s $HOME/.nix-profile/lib/nvim-treesitter-parsers/lib/nvim-treesitter-grammars/*.so parser
      else
        ln -s ${nvim-treesitter-parsers}/lib/nvim-treesitter-grammars/*.so parser
      fi
    '').overrideAttrs
      {
        passthru.rev = pkgs.vimPlugins.nvim-treesitter.src.rev;
      };

in
{
  inherit nvim nvim-nightly;
  inherit nvim-treesitter-install;
}
