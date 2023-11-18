{
  lib,
  pkgs,
  pkgsStable,
  inputs,
  ...
}: {
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
        vim-tmux-navigator
        cpu
      ];
    };
  };
}
