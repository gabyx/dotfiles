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
in {
  # Options for nvim configuration
  options.nvim = {
    enable = mkEnableOption "nvim";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pkgsStable.neovim
    ];

    home.activation.install-nvim = hm.dag.entryAfter ["installPackages"] ''
      ${builtin.toPath ./scripts/setup-nvim.sh}
    '';
  };
}
