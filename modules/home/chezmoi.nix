{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.chezmoi;
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
      export PATH="${pkgs.git-lfs}/bin:${pkgs.gitFull}/bin:${pkgs.chezmoi}/bin:${pkgs.age}/bin:${pkgs.systemd}/bin:${pkgs.libsecret}/bin:$PATH"
      ${builtins.toPath ./scripts/setup-configs.sh} \
        "${cfg.url}" "${cfg.ref}" "${cfg.workspace}"
    '';
  };
}
