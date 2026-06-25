{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
in
{
  vim.lsp.servers.presets.ty.enable = true;

  vim.lsp.servers.ty = {
    cmd = lib.mkForce [
      (resolveCmd {
        target = "ty";
      })
      "server"
    ];

    filetypes = [
      "python"
    ];

    root_markers = lib.mkForce [
      "pyproject.toml"
      "setup.py"
      "setup.cfg"
      "pyrightconfig.json"
    ];
  };
}
