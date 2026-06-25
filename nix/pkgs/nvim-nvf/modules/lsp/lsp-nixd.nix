{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  hostName = "desktop";
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit lib pkgs; }) resolveCmd;
in
{
  vim.languages.nix = {
    enable = false;
    treesitter.enable = true; # Only enable the special query setup for inline strings.

    # TODO: No nvim-lint for now.
    extraDiagnostics.enable = true;

    # We turn its
    # own LSP off so it doesn't also spawn a server alongside the nixd config
    # we register by hand below.
    lsp.enable = false;
  };

  vim.lsp.servers.nixd = {
    cmd = [ (resolveCmd { target = "nixd"; }) ];
    filetypes = [ "nix" ];

    root_markers = [
      "flake.nix"
      "tools/nix/flake.nix"
      ".git"

    ];

    settings.nixd = {
      nixpkgs.expr = "import <nixpkgs> { }";

      formatting.command = [ (lib.getExe pkgs.nixfmt) ];

      options = {
        # My expressions to parse into.
        nixos.expr = ''(builtins.getFlake "${inputs.self}").nixosConfigurations.${hostName}.options'';
        home-manager.expr = ''(builtins.getFlake "${inputs.self}").nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []'';
      };
    };
  };
}
