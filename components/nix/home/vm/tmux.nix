{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux/tmux.conf;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      cpu
    ];
  };
}
