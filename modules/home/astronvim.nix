{ config
, pkgs
, pkgsStable
, lib
, inputs
, ...
}:
with lib; let
  cfg = config.astronvim;
in
{
  # Options for nvim configuration repositories.
  options.astronvim = {
    enable = mkEnableOption "nvim";

    astroVimUrl = mkOption {
      type = types.str;
      description = "AstroVim Git repo url.";
      default = "https://github.com/AstroNvim/AstroNvim.git";
    };

    astroVimRef = mkOption {
      type = types.enum [ "main" "nightly" ];
      default = "main";
      description = "AstroVim Git branch.";
    };

    astroVimUserUrl = mkOption {
      type = types.str;
      description = "AstroVim User Git repo url.";
    };

    astroVimUserRef = mkOption {
      type = types.enum [ "main" ];
      default = "main";
      description = "AstroVimUser Git branch.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pkgsStable.neovim
    ];

    # Let home-manager clone the repos from the store and
    # replace the url of remote `origin`.
    home.activation.install-nvim = hm.dag.entryAfter [ "installPackages" ] ''
      export PATH="${pkgs.git-lfs}/bin:${pkgs.gitFull}/bin:${pkgs.chezmoi}/bin:$PATH"

      ${builtins.toPath ./scripts/setup-astronvim.sh} \
        "${cfg.astroVimUrl}" "${cfg.astroVimRef}" \
        "${cfg.astroVimUserUrl}" "${cfg.astroVimUserRef}"
    '';
  };
}
