{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
in
{
  vim.lsp.servers.tilt_ls = {
    cmd = [
      (resolveCmd { target = "tilt"; })
      "lsp"
      "start"
    ];
    filetypes = [ "tiltfile" ];
    root_markers = [ "Tiltfile" ];
  };

  vim.luaConfigRC.tiltfile-setup =
    # Lua
    ''
      vim.filetype.add({
        filename = { ["Tiltfile"] = "tiltfile" },
        pattern  = { [".*%.tilt"] = "tiltfile" },
      })

      -- Tell treesitter to highlight it with starlark parser.
      vim.treesitter.language.register("starlark", "tiltfile")
    '';
}
