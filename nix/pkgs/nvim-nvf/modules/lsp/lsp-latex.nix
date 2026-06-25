{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
in
{
  vim.lsp.servers.texlab = {
    cmd = [
      (resolveCmd "texlab")
    ];

    filetypes = [
      "tex"
      "plaintex"
      "bib"
    ];

    settings = {
      texlab = {
        build.onSave = true;
        forwardSearch = {
          executable = "zathura";
          args = [
            "--synctex-forward"
            "%l:1:%f"
            "%p"
          ];
        };
      };
    };
  };
}
