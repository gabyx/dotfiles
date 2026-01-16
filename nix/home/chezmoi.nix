{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.chezmoi;

  script = ./scripts/chezmoi/setup.sh;

  chezmoiInitRepo = pkgs.writeShellApplication {
    name = "hm-chezmoi-init-repo";

    runtimeInputs = [
      pkgs.git-lfs
      pkgs.gitFull
      pkgs.chezmoi
      pkgs.just
      pkgs.fd
    ];

    text =
      # bash
      ''
        ${script} "${cfg.url}" "${cfg.ref}" "${cfg.workspace}" "${cfg.store}" "$@"
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
      description = "The source directory to clone from.";
    };

    store = mkOption {
      type = types.path;
      description = "The store path to setup the initial Git repo.";
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

    initScript = mkOption {
      type = types.package;
      internal = true;
      default = chezmoiInitRepo;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      chezmoi
      chezmoiInitRepo
    ];

    home.activation.setup-chezmoi = hm.dag.entryAfter [ "chezmoi-init-repo" ] ''
      ${chezmoiInitRepo}/bin/hm-chezmoi-init-repo
    '';
  };
}
