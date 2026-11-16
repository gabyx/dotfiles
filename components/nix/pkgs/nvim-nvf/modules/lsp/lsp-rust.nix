{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.gabyx.lsp;

  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
in
{
  vim.lsp.presets.rust-analyzer.enable = true;

  vim.lsp.servers.rust-analyzer = {
    enable = true;

    filetypes = [
      "rust"
    ];

    cmd = lib.mkForce [ (resolveCmd "rust-analyzer" pkgs.rust-analyzer) ];

    # Do not set 'init_options': rust-analyzer auto-populates its
    # initializationOptions from `settings."rust-analyzer"` at `initialize`
    # time. Keep a single source of truth here and let the client mirror it.
    settings.rust-analyzer = {
      check = {
        command = "clippy";
        extraArgs = [ "--no-deps" ];
      };
      checkOnSave = true;
      files = {
        excludeDirs = cfg.excludeDirs;
      };
      inlayHints = {
        bindingModeHints.enable = false;
        chainingHints.enable = true;
        closingBraceHints = {
          enable = true;
          minLines = 25;
        };
        closureReturnTypeHints.enable = true;
        lifetimeElisionHints = {
          enable = true;
          useParameterNames = false;
        };
        maxLength = 25;
        parameterHints.enable = true;
        reborrowHints.enable = true;
        renderColons = true;
        typeHints = {
          enable = true;
          hideClosureInitialization = false;
          hideNamedConstructor = false;
        };
      };
    };
  };
}
