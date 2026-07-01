{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmdLua;
  enable = true;

  name = "pyright-langserver";
in
{
  vim.lsp.presets.pyright.enable = enable;

  vim.lsp.servers.pyright = lib.mkIf enable {
    cmd = lib.mkForce (resolveCmdLua name (lib.getExe' pkgs.pyright name) [ "--stdio" ]);

    filetypes = [ "python" ];

    root_markers = lib.mkForce [
      "pyproject.toml"
      "setup.py"
      "setup.cfg"
      "pyrightconfig.json"
    ];
  };
}
