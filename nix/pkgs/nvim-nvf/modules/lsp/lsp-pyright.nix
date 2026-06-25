{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
in
{
  vim.lsp.servers.presets.pyright.enable = true;

  vim.lsp.servers.pyright = {
    cmd = lib.mkForce [
      (resolveCmd {
        target = "pyright-langserver";
      })
      "--stdio"
    ];

    filetypes = [ "python" ];

    root_markers = lib.mkForce [
      "pyproject.toml"
      "setup.py"
      "setup.cfg"
      "pyrightconfig.json"
    ];
  };
}
