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
  neovim-nightly =
    let
      neovim-n = inputs.neovim-nightly.packages.${pkgs.system}.neovim;
    in
    (pkgs.writeShellScriptBin "nvim-nightly" "exec -a $0 ${neovim-n}/bin/nvim $@");
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
    home.packages = with pkgs; [
      neovim
      neovim-nightly
      tree-sitter
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
