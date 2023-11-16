{
  config,
  pkgs,
  pkgsStable,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.nvim;

  astroVimURL = "https://github.com/AstroNvim/AstroNvim.git";
  astroVimRef = cfg.astroVimRef;

  astroVim = lib.fetchGit {
    url = astroVimUser;
    ref = astroVimRef;
    shallow = true;
    leaveDotGit = true;
  };

  astroVimUserURL = "https://github.com/gabyx/astrovim.git";
  astroVimUserRef = cfg.astroVimUserRef;

  astroVimUser = lib.fetchGit {
    url = astroVimUserRef;
    ref = astroVimUserRef;
    shallow = true;
    leaveDotGit = true;
  };
in {
  # Options for nvim configuration repositories.
  options.nvim = {
    enable = mkEnableOption "nvim";

    astroVimRef = mkOption {
      type = types.enum ["stable" "nightly"];
      default = "stable";
      description = "AstroVim Git branch.";
    };

    astroVimUserUrl = mkOption {
      type = types.str;
      description = "AstroVim User Git repo url.";
    };

    astroVimUserRef = mkOption {
      type = types.enum ["main"];
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
    home.activation.install-nvim = hm.dag.entryAfter ["installPackages"] ''
      ${builtin.toPath ./scripts/setup-nvim.sh} \
        "${astroVim}" "${astroVimURL}" \
        "${astroVimUser}" "${astroVimUserURL}"
    '';
  };
}
