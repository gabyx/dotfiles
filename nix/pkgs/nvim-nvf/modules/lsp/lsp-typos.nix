{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmdLua;
in
{
  vim.lsp.servers.typos-lsp = {
    enable = true;
    cmd = resolveCmdLua "typos-lsp" pkgs.typos-lsp [ ];

    root_markers = [
      ".git"
    ];

    # typos-lsp works over any buffer's text, not language-specific syntax,
    # so it's common to just run it on everything. "*" is supported as a
    # catch-all filetype in recent Neovim/nvim-lspconfig.
    filetypes = null;
  };
}
