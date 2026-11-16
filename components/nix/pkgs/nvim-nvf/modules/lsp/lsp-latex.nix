{ lib, pkgs, ... }:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmdLua;
in
{
  vim.lsp.servers.texlab = {
    cmd = resolveCmdLua "texlab" pkgs.texlab [ "run" ];

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
