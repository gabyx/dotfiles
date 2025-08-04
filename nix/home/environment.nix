{
  config,
  pkgs,
  ...
}:
{
  home.sessionVariables = {
    TERMINAL = "wezterm";
    EDITOR = "nvim";
    EDITOR_READONLY = "nvim -R";
    BROWSER = "google-chrome-stable";
  };
}
