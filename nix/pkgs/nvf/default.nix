{
  inputs,
  inputs',
  pkgs,
  ...
}:
let
  createNeovim =
    {
      name,
      nvim,
    }:
    let
      nvimNvf =
        (inputs.nvim-nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [
            {
              vim.package = nvim;
            }
            ./modules/filetree.nix
            ./modules/git.nix
            ./modules/icons.nix
            ./modules/mappings.nix
            ./modules/plugins.nix
            ./modules/treesitter.nix
            ./modules/ui.nix
          ];
        }).neovim;

      wrapper = pkgs.callPackage ./launch.nix {
        nvim = nvimNvf;
        inherit name;
      };
    in
    {
      # The actual nvim executable.
      "${name}" = wrapper;

      # The derivation for printing the config.
      "${name}-config" =
        pkgs.writeShellScriptBin "nvim-gabyx-config" "exec -a $0 ${nvimNvf}/bin/nvf-print-config";
    };

  nvim = createNeovim {
    name = "nvim-gabyx";
    nvim = pkgs.neovim-unwrapped;
  };

  nvim-nightly = createNeovim {
    name = "nvim-gabyx-nightly";
    nvim = inputs'.nvim-nightly.packages.neovim-unwrapped;
  };
in
nvim // nvim-nightly
