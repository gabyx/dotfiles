{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.astronvim;

  # Add the nightly neovim too.
  nvim-nightly =
    let
      neovim-n = inputs.nvim-nightly.packages.${pkgs.system}.neovim;
    in
    (pkgs.writeShellScriptBin "nvim-nightly" "exec -a $0 ${neovim-n}/bin/nvim $@");

  # TODO: Bundle treesitter.
  # Mic92 uses also astronvim and lazy
  # src: https://github.com/Mic92/dotfiles/tree/main/home/.config/nvim
  # all treesitter parsers are bundled with nvim:
  # https://github.com/Mic92/dotfiles/blob/d2b255785d3a70cbbf100993f1dc2a4171d75bcf/home-manager/modules/neovim/flake-module.nix
  # He uses the `nvim-treesitter-install` inside:
  # https://github.com/Mic92/dotfiles/blob/main/home/.config/nvim/init.lua#L52
  # https://github.com/Mic92/dotfiles/blob/main/home/.config/nvim/lua/plugins/treesitter.lua#L3

  neovim = pkgs.unstable.neovim;
in
{
  # Options for nvim configuration repositories.
  options.astronvim = {
    enable = mkEnableOption "nvim";

    url = mkOption {
      type = types.str;
      description = "AstroNvim Git repo url.";
      default = "https://github.com/gabyx/astronvim.git";
    };

    ref = mkOption {
      type = types.enum [ "main" ];
      default = "main";
      description = "AstroNvim Git branch.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      neovim
      nvim-nightly
      pkgs.unstable.tree-sitter
    ];

    # Let home-manager clone the repos from the store and
    # replace the url of remote `origin`.
    home.activation.install-nvim = hm.dag.entryAfter [ "installPackages" ] ''
      export PATH="${pkgs.git-lfs}/bin:${pkgs.gitFull}/bin:${pkgs.chezmoi}/bin:$PATH"

      ${builtins.toPath ./scripts/setup-astronvim.sh} \
        "${cfg.url}" "${cfg.ref}" \
    '';
  };
}
