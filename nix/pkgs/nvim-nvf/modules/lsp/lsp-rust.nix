{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.nvim.lua) toLuaObject;
  cfg = config.gabyx.lsp;

  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
in
{
  vim.languages.rust.enable = true;
  vim.languages.rust.lsp = {
    enable = true;

    package = [ (resolveCmd "rust-analyzer" pkgs.rust-analyzer) ];

    opts =
      # Lua
      ''
        ["rust-analyzer"] = {
          check = {
            command = "clippy",
            extraArgs = { "--no-deps" }
          },
          checkOnSave = true,
          files = {
            excludeDirs = ${toLuaObject cfg.excludeDirs}
          },
          inlayHints = {
            bindingModeHints = {
              enable = false
            },
            chainingHints = {
              enable = true
            },
            closingBraceHints = {
              enable = true,
              minLines = 25
            },
            closureReturnTypeHints = {
              enable = true
            },
            lifetimeElisionHints = {
              enable = true,
              useParameterNames = false
            },
            maxLength = 25,
            parameterHints = {
              enable = true
            },
            reborrowHints = {
              enable = true
            },
            renderColons = true,
            typeHints = {
              enable = true,
              hideClosureInitialization = false,
              hideNamedConstructor = false
            }
          }
        }
      '';
  };
}
