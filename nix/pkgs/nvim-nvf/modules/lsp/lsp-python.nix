{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
  enable = true;
in
{
  vim.lsp.servers.presets.pyright.enable = enable;

  vim.lsp.servers.pyright = lib.mkIf enable {
    cmd = lib.mkForce [
      (resolveCmd "pyright-langserver")
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
