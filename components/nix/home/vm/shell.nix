{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
let
  antidote = pkgs.callPackage ./shell/antidote/default.nix { };
in
{
  xdg = {
    enable = true;
    configFile.p10k = {
      source = ./shell/.p10k.zsh;
      target = "zsh/.p10k.zsh";
    };
    configFile.keybindings = {
      source = ./shell/.zshrc-keybindings.zsh;
      target = "zsh/.zshrc-keybindings.zsh";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
  };

  programs.zsh =
    let
      antidote-init = import ./shell/antidote/init.nix { inherit antidote; };
    in
    {
      enable = true;

      enableCompletion = false;
      syntaxHighlighting.enable = false;

      dotDir = "${config.xdg.configHome}/zsh";

      history = {
        path = "$ZDOTDIR/.zsh_history";
        size = 10000;
        share = true;
      };

      initContent = lib.mkMerge [
        (lib.mkBefore ''
          local ZVM_LAZY_KEYBINDINGS=true
          # Somehow zsh-vi-mode overwrites CTRL+R. https://github.com/jeffreytse/zsh-vi-mode/issues/242
          local ZVM_INIT_MODE=sourcing
        '')
        (lib.mkAfter antidote-init)
        (lib.mkAfter ''
          # Init Extra -----------------------
          if [ -f "$ZDOTDIR/.p10k.zsh" ]; then
              source "$ZDOTDIR/.p10k.zsh"
          fi

          source "$ZDOTDIR/.zshrc-keybindings.zsh"

          echo "Welcome to"
          ${pkgs.figlet}/bin/figlet "${osConfig.networking.hostName}"
          ${pkgs.fastfetch}/bin/fastfetch \
            -s title:separator:os:kernel:uptime:shell:cpu:memory:disk \
            -l none \
            -c examples/28
        '')
      ];
    };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
