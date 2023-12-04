{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    TERMINAL = "wezterm";
    EDITOR = "nvim";
    BROWSER = "google-chrome-stable";
  };
}
