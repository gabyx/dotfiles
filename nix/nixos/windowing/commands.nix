{
  lib,
  writeShellApplication,
  windowMgr,
  ...
}:
let
  isHyprland = windowMgr == "hyprland";
  isSway = windowMgr == "sway";

  cmds = {
    term.cmd = "wezterm start --always-new-process";
    term-start.cmd = "~/.config/sway/scripts/start-term.sh";

    file-manager.cmd = ''kitty -- zsh "-c" "lf"'';

    display-manager.cmd =
      if isSway then
        "way-displays"
      else
        ''
          die "No display manager defined."
        '';

    launcher-menu.cmd = "~/.config/rofi/show-launcher-menu.sh";
    power-menu.cmd = "~/.config/rofi/show-power-menu.sh";
    wireless-menu.cmd = "~/.config/rofi/show-network-menu.sh --wireless";
    network-menu.cmd = "~/.config/rofi/show-network-menu.sh --editor";
    bluetooth-menu.cmd = "rofi-bluetooth";
    emoji-menu.cmd = "rofimoji --clipboarder wl-copy --action type copy --keybinding-copy Ctrl-y";
    systemd-menu.cmd = "rofi-systemd";
    procs-menu.cmd = "kitty btop";
    sound-menu.cmd = "pavucontrol";
    calculator-menu.cmd = "qalculate-gtk";
    screenshot-menu.cmd = "~/.config/rofi/scripts/rofi-screenshot.sh";
    screenrecord-menu.cmd = "~/.config/rofi/scripts/rofi-screenrecord.sh";
    color-picker-menu.cmd = "~/.config/rofi/scripts/rofi-color-picker.sh";
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
