{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    TERMINAL = "wezterm";
    EDITOR = "nvim";
  };
}
