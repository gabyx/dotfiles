{
  lib,
  pkgs,
  ...
}:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmdLua;
  enable = false;
in
{
  vim.lsp.servers.presets.ty.enable = enable;

  vim.lsp.servers.ty = lib.mkIf enable {
    cmd = lib.mkForce (resolveCmdLua "ty" pkgs.ty [ ]);

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
