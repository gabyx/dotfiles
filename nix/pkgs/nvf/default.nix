{
  lib,
  inputs,
  inputs',
  pkgs,
  pkgsUnstable,
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

          extraSpecialArgs = {
            inherit pkgsUnstable;
          };

          modules = [
            {
              vim = {
                package = nvim;
                appName = name; # FIXME: Remove when going to upstream.
              };
              imports = [
                (inputs.import-tree (i: i.map (x: lib.info "Importing: '${x}'" x)) (
                  i: i.filter (x: !lib.hasInfix ".lib." x)
                ) [ ./modules ])
              ];
            }
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
