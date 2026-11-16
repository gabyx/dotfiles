{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmdLua;
in
{
  vim.lsp.servers.tilt_ls = {
    cmd = resolveCmdLua "tilt" pkgs.tilt [
      "lsp"
      "start"
    ];
    filetypes = [ "tiltfile" ];
    root_markers = [ "Tiltfile" ];
  };

  vim.filetype = {
    filename = {
      "Tiltfile" = "tiltfile";
    };
    pattern = {
      ".*%.tilt" = "tiltfile";
    };
  };

  vim.luaConfigRC.tiltfile-setup =
    # Lua
    ''
      -- Tell treesitter to highlight it with starlark parser.
      vim.treesitter.language.register("starlark", "tiltfile")
    '';
}
