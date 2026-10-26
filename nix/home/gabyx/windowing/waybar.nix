{ lib, osConfig, ... }:
let
  windowMgr = lib.strings.toLower osConfig.settings.windowing.manager;
in
{
  xdg.configFile."waybar/style.css" = {
    force = true;
    source = ../../config/waybar/style.css;
  };

  xdg.configFile."waybar/config" = {
    force = true;
    text = lib.generators.toJSON { } {
      # -------------------------------------------------------------------------
      # Global configuration
      # -------------------------------------------------------------------------

      layer = "top";
      position = "top";

      margin-top = 0;
      margin-left = 0;
      margin-right = 0;
      margin-bottom = 0;

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
        "custom/media-player"
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
        exec = "gabyx waybar tooltip 'Calculator'";
        interval = "once";
        on-click = "gabyx windowing mgr-exec gabyx windowing calculator-menu";
        tooltip = true;
      };

      "custom/emoji" = {
        format = " ";
        return-type = "json";
        exec = "gabyx waybar tooltip 'Symbols/Emojis'";
        interval = "once";
        on-click = "gabyx windowing mgr-exec gabyx windowing emoji-menu";
        tooltip = true;
      };

      "custom/screenshot" = {
        format = "󰄀";
        return-type = "json";
        exec = "gabyx waybar tooltip 'Screenshot'";
        interval = "once";
        on-click = "gabyx windowing mgr-exec gabyx windowing screenshot-menu";
        tooltip = true;
      };

      "custom/ssh" = {
        format = "{icon}";
        return-type = "json";
        exec = "gabyx waybar ssh-connections";
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
        exec = "gabyx waybar backup";
        interval = 5;

        format-icons = {
          running = "󰦘";
          failure = "󰲼";
          success = "󰦕";
        };

        tooltip = true;
      };

      # Hidden if no player is running (no icon for `none`).
      "custom/media-player" = {
        format = "{icon}";
        return-type = "json";
        exec = "gabyx waybar media-player";
        interval = 2;
        format-icons = {
          playing = "󰐊";
          paused = "󰏤";
        };
        tooltip = true;
        on-click = "gabyx waybar media-player toggle";
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
        on-click = "gabyx windowing mgr-exec gabyx windowing storage-menu";
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
        exec = "gabyx waybar next-meeting";
        on-click-right = "kitty -- /usr/bin/env bash -c ikhal";
        on-click = "gabyx waybar next-meeting --open-url";
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

        on-click = "gabyx windowing mgr-exec gabyx windowing procs-menu";
        on-click-right = "gabyx windowing mgr-exec gabyx windowing systemd-menu";
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

        on-scroll-up = "gabyx windowing mgr-exec gabyx windowing brightness-up";
        on-scroll-down = "gabyx windowing mgr-exec gabyx windowing brightness-down";
      };

      "custom/vpn" = {
        format = "{icon}";
        exec = "gabyx waybar vpn-status";
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

        on-click = "gabyx windowing mgr-exec gabyx windowing wireless-menu";
        on-click-right = "gabyx windowing mgr-exec gabyx windowing network-menu";
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
        format = "{icon} {name}";
        format-icons = {
          urgent = "";
          focused = "";
          default = "";
        };
      };

      "niri/workspaces" = {
        all-outputs = false;
        hide-empty = true;
        format = "{icon} {value}";
        format-icons = {
          urgent = "";
          focused = "";
          default = "";
        };
      };

      "hyprland/workspaces" = {
        all-outputs = false;
        format = "{icon} {name}";
        format-icons = {
          urgent = "";
          focused = "";
          default = "";
        };
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

        on-click = "gabyx windowing mgr-exec gabyx windowing sound-menu";
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

        on-click-right = "gabyx windowing mgr-exec gabyx windowing bluetooth-menu";
        tooltip-format = "{status}";
      };

      "custom/powermenu" = {
        format = " ";
        on-click = "gabyx windowing mgr-exec gabyx windowing power-menu";
        tooltip = false;
      };

      "custom/launcher" = {
        format = " ";
        on-click = "gabyx windowing mgr-exec gabyx windowing launcher-menu";
        tooltip = false;
      };

      tray = {
        icon-size = 15;
        spacing = 7;
      };
    };
  };
}
