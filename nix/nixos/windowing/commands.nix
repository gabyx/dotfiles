{
  lib,
  writeShellApplication,
  windowMgr,
  ...
}:
let
  isHyprland = windowMgr == "hyprland";
  isSway = windowMgr == "sway";
  isNiri = windowMgr == "niri";

  cmds = {
    term.cmd = "gabyx term start";
    term-start.cmd = "gabyx term start-into-tmux";

    file-manager.cmd = "gabyx::term lf";

    display-manager.cmd =
      if isSway || isNiri then
        "way-displays"
      else
        ''
          gabyx::die "No display manager defined."
        '';

    launcher-menu.cmd = "gabyx rofi launcher";
    power-menu.cmd = "gabyx rofi power";
    wireless-menu.cmd = "gabyx rofi network wireless";
    network-menu.cmd = "gabyx rofi network editor";
    bluetooth-menu.cmd = "rofi-bluetooth";
    emoji-menu.cmd = "rofimoji --clipboarder wl-copy --action type copy --keybinding-copy Ctrl-y";
    systemd-menu.cmd = "gabyx rofi systemd";
    passwdmgr-menu.cmd = "rofi-rbw";
    procs-menu.cmd = "gabyx::term btop";
    sound-menu.cmd = "pavucontrol";
    calculator-menu.cmd = "qalculate-gtk";
    screenshot-menu.cmd = "gabyx rofi screenshot";
    screenrecord-menu.cmd = "gabyx rofi screenrecord";
    color-picker-menu.cmd = "gabyx rofi color-picker";
    copy-menu.cmd = "copyq toggle";

    brightness-up.cmd = "brightnessctl set '10%+'";
    brightness-down.cmd = "brightnessctl set '10%-'";

    clipboard.cmd = "copyq --start-server";
    clipboard-menu.cmd = "copyq toggle";

    notifications.cmd = "swaync";
    notification-menu.cmd = "swaync-client -t -sw";

    nightshifter.cmd = "gammastep-indicator";
  };

  mkEnvStr = env: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''export ${k}="${v}"'') env);

  allCmds = lib.mapAttrsToList (
    name:
    {
      cmd,
      env ? { },
    }:
    writeShellApplication {
      name = "gabyx::${name}";
      text = ''
        function die() {
            if command -v notify-send &>/dev/null; then
                notify-send --category warning "$@" || true
            else
                echo -e "$@" >&2
            fi
            exit 1
        }

        ${mkEnvStr env}
        exec ${cmd} "$@"
      '';
    }
  ) cmds;

  # Execute over the window manager.
  windowMgrExec = writeShellApplication {
    name = "gabyx::window-mgr-exec";
    text =
      if isSway then
        ''
          exec swaymsg exec "$@"
        ''
      else if isNiri then
        ''
          exec niri msg action spawn -- "$@"
        ''
      else if isHyprland then
        ''
          exec hyprctl dispatch exec "$@"
        ''
      else
        ''
          echo "Window manager is not defined." >&2
        '';
  };
in
allCmds ++ [ windowMgrExec ]
