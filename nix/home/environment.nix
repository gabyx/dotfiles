{
  lib,
  pkgsUnstable,
  ...
}:
{
  home.sessionVariables = {
    TERMINAL = "wezterm";
    EDITOR = "nvim";
    EDITOR_READONLY = "nvim -R";
    BROWSER = "google-chrome-stable";

    # ZSH plugin is disabled to download it.
    GITSTATUS_DAEMON = "${lib.getExe pkgsUnstable.gitstatus}";
  };
}
