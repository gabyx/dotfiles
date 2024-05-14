{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    TERMINAL = "wezterm";
    EDITOR = "nvim";
    BROWSER = "google-chrome-stable";

    # For nextmeeting.
    GCALCLI_DEFAULT_CALENDAR = config.settings.user.email;
  };
}
