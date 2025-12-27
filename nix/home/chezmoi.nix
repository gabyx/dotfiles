{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.chezmoi;

  script = ./scripts/shell/chezmoi/setup.sh;

  scriptDrv = pkgs.writeShellApplication {
    name = "setup";

    runtimeInputs = [
      pkgs.git-lfs
      pkgs.gitFull
      pkgs.chezmoi
      pkgs.just
    ];

    text =
      # bash
      ''
        ${script} "${cfg.url}" "${cfg.ref}" "${cfg.workspace}"
      '';
  };
in
{
  # Options for chezmoi configuration
  options.chezmoi = {
    enable = mkEnableOption "chemzoi";

    package = mkOption {
      type = types.package;
      default = pkgs.chezmoi;
      description = "The chezmoi package to use.";
    };

    url = mkOption {
      type = types.str;
      description = "The source directory to use for generating dotfiles.";
    };

    ref = mkOption {
      type = types.str;
      description = "The Chezmoi Git.";
    };

    workspace = mkOption {
      type = types.enum [
        "private"
        "work"
      ];
      default = "private";
      description = "Chezmoi `workspace` setting inside `.chezmoi.yaml.tmpl`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ chezmoi ];

    home.activation.install-chezmoi = hm.dag.entryAfter [ "installPackages" ] ''
      ${scriptDrv}/bin/setup
    '';
  };
}
