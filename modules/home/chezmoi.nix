{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.chezmoi;
in {
  # Options for chezmoi configuration
  options.chezmoi = {
    enable = mkEnableOption "chemzoi";

    package = mkOption {
      type = types.package;
      default = pkgs.chezmoi;
      description = "The chezmoi package to use.";
    };

    sourceDir = mkOption {
      type = types.path;
      description = "The source directory to use for generating dotfiles.";
    };

    workspace = mkOption {
      type = types.str;
      default = "private";
      description = "Chezmoi `workspace` setting inside `.chezmoi.yaml.tmpl`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      chezmoi
    ];

    home.activation.install-chezmoi = hm.dag.entryAfter ["installPackages"] ''
      ${builtin.toPath ./scripts/setup-config-files.sh} "${cfg.workspace}"
    '';
  };
}
