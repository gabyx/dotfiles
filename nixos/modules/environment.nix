{ config, pkgs, ... }:

{
  ### Environment ================================================================
  environment = {
    shells = [
      "/run/current-system/sw/bin/zsh"
    ];

    sessionVariables = {
      TERMINAL = "wezterm";
      EDITOR = "nvim";
    };
  };
  # ===========================================================================
}
