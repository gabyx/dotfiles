{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.chezmoi;

  chezmoi = lib.fetchGit {
    url = cfg.url;
    ref = cfg.ref;
    shallow = true;
    leaveDotGit = true;
  };
in {
  # Options for chezmoi configuration
  options.chezmoi = {
    enable = mkEnableOption "chemzoi";

    package = mkOption {
      type = types.package;
      default = pkgs.chezmoi;
      description = "The chezmoi package to use.";
    };

    url = mkOption {
      type = types.path;
      description = "The source directory to use for generating dotfiles.";
    };

    ref = mkOption {
      type = types.str;
      description = "The Chezmoi Git.";
    };

    workspace = mkOption {
      type = types.enum ["private" "work"];
      default = "private";
      description = "Chezmoi `workspace` setting inside `.chezmoi.yaml.tmpl`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      chezmoi
    ];

    home.activation.install-chezmoi = hm.dag.entryAfter ["installPackages"] ''
      ${builtin.toPath ./scripts/setup-config-files.sh} \
        "${chezmoi}" "${cfg.url}" ${cfg.workspace}"
    '';
  };
}
