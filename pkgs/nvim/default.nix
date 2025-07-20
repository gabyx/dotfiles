{
  inputs,
  pkgs,
  ...
}:
let
  createNeovim =
    nvimDrv:
    (inputs.nvim-nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [
        {
          vim.package = nvimDrv;
        }
        ./plugins.nix
        ./treesitter.nix
      ];
    }).neovim;

  nvim = createNeovim pkgs.neovim-unwrapped;
  nvim-nightly = createNeovim inputs.nvim-nightly.packages.${pkgs.system}.neovim-unwrapped;

  # Wrap to other name.
  nvim-gabyx = (pkgs.writeShellScriptBin "nvim-gabyx" "exec -a $0 ${nvim}/bin/nvim \"$@\"");
  nvim-gabyx-config = (
    pkgs.writeShellScriptBin "nvim-gabyx-config" "exec -a $0 ${nvim}/bin/nvf-print-config"
  );

  nvim-gabyx-nightly = (
    pkgs.writeShellScriptBin "nvim-gabyx-nightly" "exec -a $0 ${nvim-nightly}/bin/nvim \"$@\""
  );
in
{
  inherit
    nvim
    nvim-nightly

    nvim-gabyx
    nvim-gabyx-config
    nvim-gabyx-nightly
    ;
}
