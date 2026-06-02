{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  cfg = config.settings;
in
{
  home.sessionVariables = {
    TERMINAL = "${lib.getExe (lib.elemAt cfg.programs.terminals 0)}";
    EDITOR = "${lib.getExe (lib.elemAt cfg.programs.editors 0)}";
    EDITOR_READONLY = "${lib.getExe (lib.elemAt cfg.programs.editors 0)} -R";

    BROWSER = "${lib.getExe config.settings.programs.browser}";

    # ZSH plugin is disabled to download it.
    GITSTATUS_DAEMON = "${lib.getExe pkgsUnstable.gitstatus}";
  };
}
