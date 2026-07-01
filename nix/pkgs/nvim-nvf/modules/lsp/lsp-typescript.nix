{
  lib,
  pkgs,
  ...
}:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmdLua;
in
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.presets.typescript-go.enable = true;

  vim.lsp.servers.typescript-go = {
    cmd = lib.mkForce (
      resolveCmdLua "typescript-go" pkgs.typescript-go [
        "--lsp"
        "--stdio"
      ]
    );

    filetypes = [
      "typescript"
    ];
  };
}
