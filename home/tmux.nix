{
  lib,
  config,
  osConfig,
  pkgs,
  pkgsStable,
  inputs,
  ...
}:
{
  programs = {
    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = ''
            # Todo should go to `extraConfigBeforePlugins` see
            # https://github.com/nix-community/home-manager/pull/4670
            source-file ~/.config/tmux/tmux-custom.conf
            source-file ~/.config/tmux/tmux-plugin-resurrect.conf
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            source-file ~/.config/tmux/tmux-plugin-continuum.conf
          '';
        }
        urlview
        vim-tmux-navigator
        cpu
      ];
    };
  };

  home.packages = with pkgs; [ tmuxifier ];

  # We need this file to source in `~/.config/sway/scripts/start-up.sh`
  # to be able to properly start tmux because these variables are not
  # yet sourced.
  xdg.configFile."tmux/.tmux-env".text = ''
    export TMUX_TMPDIR="${config.home.sessionVariables.TMUX_TMPDIR}"
  '';
}
