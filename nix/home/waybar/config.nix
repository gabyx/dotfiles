{ lib, osConfig, ... }:
let
  windowMgr = lib.strings.toLower osConfig.settings.windowing.manager;

  format-icons = {
    ws-1 = "1: ";
    ws-2 = "2: ";
    ws-3 = "3: ";
    ws-4 = "4: ";

    ws-5 = "5: ";
    ws-6 = "6: ";

    ws-comm = "7: ";
    ws-mail = "8: ";
    ws-web = "9: ";
    ws-creds = "0: 󱕴";

    urgent = "";
    focused = "";
    default = "";
  };
in
{
  xdg.configFile."waybar/config" = {
    force = true;
    text = lib.generators.toJSON {
      # -------------------------------------------------------------------------
      # Global configuration
      # -------------------------------------------------------------------------

      layer = "top";
      position = "top";

      # If height property would be not present, it'd be calculated dynamically
      height = 30;

      modules-left = [
        "custom/launcher"
      ]
      ++ lib.optionals (windowMgr == "sway") [
        "sway/workspaces"
        "sway/mode"
        "sway/window"
      ]
      ++ lib.optionals (windowMgr == "hyprland") [
        "hyprland/workspaces"
        "hyprland/submap"
        "hyprland/window"
      ]
      ++ lib.optionals (windowMgr == "niri") [
        "niri/workspaces"
        "niri/window"
      ];

      modules-center = [
        "custom/agenda"
        "clock#date"
        "clock#time"
      ];

      modules-right = [
        "tray"
        "custom/calculator"
        "custom/emoji"
        "custom/screenshot"
        "custom/backup"
        "backlight"
        "memory"
        "cpu"
        "temperature"
        "disk"
        "custom/ssh"
      ]
      ++ lib.optionals (windowMgr == "sway") [
        "sway/language"
      ]
      ++ lib.optionals (windowMgr == "hyprland") [
        "hyprland/language"
      ]
      ++ lib.optionals (windowMgr == "niri") [
        "niri/language"
      ]
      ++ [
        "custom/vpn"
        "network"
        "bluetooth"
        "pulseaudio"
        "battery"
        "custom/notification"
        "custom/powermenu"
      ];

      # -------------------------------------------------------------------------
      # Modules
      # -------------------------------------------------------------------------

      "custom/calculator" = {
        format = " ";
        return-type = "json";
        exec = "~/.config/waybar/scripts/tooltip.sh 'Calculator'";
        interval = "once";
        on-click = "gabyx::window-mgr-exec gabyx::calculator-menu";
        tooltip = true;
      };

      "custom/emoji" = {
        format = " ";
        return-type = "json";
        exec = "~/.config/waybar/scripts/tooltip.sh 'Symbols/Emojis'";
        interval = "once";
        on-click = "gabyx::window-mgr-exec gabyx::emoji-menu";
        tooltip = true;
      };

      "custom/screenshot" = {
        format = "󰄀";
        return-type = "json";
        exec = "~/.config/waybar/scripts/tooltip.sh 'Screenshot'";
        interval = "once";
        on-click = "gabyx::window-mgr-exec gabyx::screenshot-menu";
        tooltip = true;
      };

      "custom/ssh" = {
        format = "{icon}";
        return-type = "json";
        exec = "~/.config/waybar/scripts/ssh-connections.sh";
        interval = 5;

        format-icons = {
          none = "󰌺";
          some = "󰌹";
        };

        tooltip = true;
      };

      "custom/backup" = {
        format = "{icon}";
        return-type = "json";
        exec = "~/.config/waybar/scripts/backup-watcher.sh";
        interval = 5;

        format-icons = {
          running = "󰦘";
          failure = "󰲼";
          success = "󰦕";
        };

        tooltip = true;
      };

      battery = {
        interval = 10;

        states = {
          warning = 30;
          critical = 15;
          supercritical = 8;
        };

        # Connected to AC
        format = "  {icon}  {capacity}%";

        # Not connected to AC
        format-discharging = "{icon}  {capacity}%";

        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];

        tooltip = true;
      };

      disk = {
        format = "  {percentage_used}%";
        format-alt = "  {percentage_used}% ";
        format-alt-click = "click-right";
        return-type = "json";
        on-click = "gabyx::window-mgr-exec gabyx::storage-menu";
        interval = 60;
        path = "/";
      };

      "clock#time" = {
        interval = 1;
        format = "󰅐  {:%H:%M}";
        tooltip = false;
      };

      "clock#date" = {
        interval = 10;
        format = "  {:%e %b %Y}";
        tooltip-format = "{:%e %B %Y}";
        on-click = "zenity --calendar";
      };

      "custom/agenda" = {
        format = "{}";
        exec = "~/.config/waybar/scripts/nextmeeting-khal.py --config ~/.config/khal/nextmeeting-conf.json";
        on-click-right = "kitty -- /usr/bin/env bash -c ikhal";
        on-click = "~/.config/waybar/scripts/nextmeeting-khal.py --config ~/.config/khal/nextmeeting-conf.json --open-url";
        interval = 59;
        return-type = "json";
        tooltip = "true";
      };

      cpu = {
        interval = 5;
        format = " {usage}%";

        states = {
          warning = 70;
          critical = 90;
        };

        on-click = "gabyx::window-mgr-exec gabyx::procs-menu";
        on-click-right = "gabyx::window-mgr-exec gabyx::systemd-menu";
      };

      "sway/language" = {
        format = "  {long} {variant}";
        on-click = "swaymsg input type:keyboard xkb_switch_layout next";
      };

      "hyprland/language" = {
        format = "  {}";
        keyboard-name = "at-translated-set-2-keyboard";
        on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
      };

      "niri/language" = {
        format = "  {}";
        on-click = "niri msg action switch-layout next";
      };

      memory = {
        interval = 5;
        format = " {}%";

        states = {
          warning = 70;
          critical = 90;
        };
      };

      backlight = {
        format = "{icon} {percent}%";

        format-icons = [
          "󰃞"
          "󰃟"
          "󰃠"
        ];

        on-scroll-up = "gabyx::window-mgr-exec gabyx::brightness-up";
        on-scroll-down = "gabyx::window-mgr-exec gabyx::brightness-down";
      };

      "custom/vpn" = {
        format = "{icon}";
        exec = "~/.config/waybar/scripts/vpn-status.sh";
        interval = 5;

        format-icons = [
          ""
          ""
        ];

        return-type = "json";
        tooltip = true;
      };

      network = {
        interval = 5;
        format-wifi = "   {signalStrength}%";
        format-ethernet = "󰈀 ";
        format-disconnected = "󰖪 ";

        tooltip-format = "{ifname}: {ipaddr}";
        tooltip-format-wifi = "{essid} | {signalStrength}%: {ipaddr}";

        on-click = "gabyx::window-mgr-exec gabyx::wireless-menu";
        on-click-right = "gabyx::window-mgr-exec gabyx::network-menu";
      };

      "sway/mode" = {
        format = "<span style=\"italic\">  {}</span>";
        tooltip = false;
      };

      "sway/window" = {
        format = "{title}";
        max-length = 20;
      };

      "sway/workspaces" = {
        window-rewrite = { };
        all-outputs = false;
        disable-scroll = false;
        smooth-scrolling-threshold = 10;
        format = "{icon}  {name}";
        inherit format-icons;
      };

      "niri/workspaces" = {
        all-outputs = false;
        hide-empty = true;
        format = "{icon}  {name}";
        inherit format-icons;
      };

      "hyprland/workspaces" = {
        all-outputs = false;
        inherit format-icons;
      };

      pulseaudio = {
        scroll-step = 10;
        format = "{icon}  {volume}%";
        format-bluetooth = "{icon}  {volume}%";
        format-muted = "";

        format-icons = {
          headphones = "";
          handsfree = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";

          default = [
            ""
            ""
          ];
        };

        on-click = "gabyx::window-mgr-exec gabyx::sound-menu";
      };

      temperature = {
        critical-threshold = 80;
        interval = 5;
        format = "{icon} {temperatureC}°C";

        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];

        tooltip = true;
      };

      "custom/notification" = {
        tooltip = false;
        format = "{icon}";

        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>";
          none = "";
          dnd-notification = "<span foreground='red'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification = "<span foreground='red'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
          dnd-inhibited-none = "";
        };

        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
        escape = true;
      };

      bluetooth = {
        format = "{icon}";
        format-alt = "bluetooth: {status}";
        interval = 30;

        format-icons = {
          enabled = "";
          disabled = "󰂲";
        };

        on-click-right = "gabyx::window-mgr-exec gabyx::bluetooth-menu";
        tooltip-format = "{status}";
      };

      "custom/powermenu" = {
        format = " ";
        on-click = "gabyx::window-mgr-exec gabyx::power-menu";
        tooltip = false;
      };

      "custom/launcher" = {
        format = " ";
        on-click = "gabyx::window-mgr-exec gabyx::launcher-menu";
        tooltip = false;
      };

      tray = {
        icon-size = 15;
        spacing = 7;
      };
    };
  };
}
