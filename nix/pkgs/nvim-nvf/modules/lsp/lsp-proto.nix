{
  pkgs,
  lib,
  ...
}:
let
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
in
{
  vim.lsp.servers.protobuf = {
    enable = true;

    filetypes = [
      "proto"
    ];

    cmd = lib.mkForce [
      (resolveCmd "buf" pkgs.buf)
      "lsp"
      "serve"
      "--timeout=0"
      "--log-format=text"
    ];
  };
}
