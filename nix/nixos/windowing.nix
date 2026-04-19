{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  inherit (lib) types mkOption;
  windowMgr = config.settings.windowing.manager;
  isHyprland = windowMgr == "hyprland";
  isSway = windowMgr == "sway";

  sessionType = "wayland";
  desktopType = if isSway then "sway" else "Hyprland";

  waylandEnvs = {
    NIXOS_OZONE_WL = 1;
    GDK_BACKEND = "${sessionType},x11";
    CLUTTER_BACKEND = sessionType;

    SDL_VIDEODRIVER = sessionType;

    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = sessionType;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    _JAVA_AWT_WM_NONREPARENTING = 1;
  };

  desktopEnvs = {
    XDG_SESSION_DESKTOP = desktopType;
    XDG_CURRENT_DESKTOP = desktopType;
  };

  envToShell =
    envs:
    (builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''export ${k}="${toString v}";'') envs));

  adjustKeyring = ''
    # Adds some more components to the gnome keyring daemon.
    export GNOME_KEYRING_CONTROL="/run/user/$UID/keyring"
    eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,gpg);
  '';

  commands = pkgs.callPackage ./windowing/commands.nix { inherit windowMgr; };

  commonPkgs =
    with pkgs;
    [
      power-profiles-daemon

      libnotify # Provides notify-send.

      way-displays # Manage your displays.

      xdg-utils # xdg-open and others utilities.
      flashfocus # Flash focus animations in sway.
      copyq # Clipboard manager.
      qalculate-gtk # Calculator menu.

      wl-clipboard # Wayland clipboard.
      wf-recorder # Wayland screen recorder.
      grim # Screenshot tool in Wayland.
      slurp # Wayland region selector.

      swappy # Edit tool for screenshots.
      gcolor3 # Colorwheel picker.
      hyprpicker # Colorpicker on screen.

      rofi # Menus for various things.
      rofimoji # Emoji selector.
      rofi-power-menu # Rofi powermenu.
      rofi-bluetooth # Rofi bluetooth.
      rofi-systemd # Rofi systemd.

      avizo # Nice brightnessctl and audio volume visualization for wayland.
      brightnessctl # Brightness control in waybar.
      playerctl # Player control in waybar.

      waybar # The top bar.
    ]
    ++ (lib.optionals isSway [
      pkgs.i3-back
      pkgs.sway-contrib.grimshot
      pkgs.swaylock-effects # Swaylock but with more effects.
      pkgs.swayidle
      pkgs.swaynotificationcenter
    ])
    ++ (lib.optionals isHyprland [
      pkgsUnstable.hypridle
      pkgsUnstable.hyprlock
      pkgsUnstable.hyprpaper
      pkgsUnstable.hyprshot
      pkgsUnstable.swaynotificationcenter
      pkgsUnstable.grimblast
    ])
    ++ commands;

in
{
  options = {
    # My settings.
    settings.windowing = {
      manager = mkOption {
        description = "Window manager to use.";
        default = "sway";
        type = types.enum [
          "sway"
          "hyprland"
        ];
      };

      isTiling = mkOption {
        description = "If the window manager is tiling.";
        internal = true;
        default =
          config.settings.windowing.manager == "sway" || config.settings.windowing.manager == "hyprland";
      };
    };
  };

  config = {
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.autorun = true;

    # Display Manager ===========================================================
    services.displayManager = {
      autoLogin.enable = false;
      autoLogin.user = "nixos";
      gdm = {
        enable = true;
        wayland = true;
      };
    };

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
    # ===========================================================================

    # Hyprland Window Manager ===================================================
    programs.hyprland = {
      enable = isHyprland;
      package = pkgsUnstable.hyprland;
      xwayland.enable = true; # Bridge to Wayland API for X11 apps.
    };

    services.hypridle = {
      enable = isHyprland;
    };

    programs.hyprlock = {
      enable = isHyprland;
    };

    environment.corePackages = lib.mkIf isHyprland commonPkgs;
    # ===========================================================================

    # Sway Window Manager
    # ===========================================================================
    programs.sway = {
      enable = isSway;
      xwayland.enable = true;
      wrapperFeatures.gtk = true; # so that gtk works properly

      extraPackages = commonPkgs;

      extraSessionCommands = (envToShell waylandEnvs) + (envToShell desktopEnvs) + adjustKeyring;
    };
    # ===========================================================================

    environment.variables = {
      XDG_SESSION_TYPE = sessionType;
    }
    // desktopEnvs;

    # To make screencasting work in Chrome and other Apps communicating
    # over DBus.
    xdg.portal = {
      enable = true;
      extraPortals = [
        (if isSway then pkgs.xdg-desktop-portal-wlr else config.programs.hyprland.portalPackage)
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # Keyring Service
    services.gnome.gnome-keyring = {
      enable = true;
    };
    security = {
      polkit.enable = true; # https://discourse.nixos.org/t/sway-does-not-start/22354/5

      pam.services = {
        login.enableGnomeKeyring = true;
      };
      # Enable Keyring for sway and swaylock.
      # // (lib.mkIf (config.settings.windowing.manager == "sway") {
      #   sway.enableGnomeKeyring = true;
      #   swaylock.enableGnomeKeyring = true;
      # });
    };

    fonts.packages = with pkgs; [
      # Waybar
      font-awesome
      cantarell-fonts
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.noto
      nerd-fonts.jetbrains-mono
    ];
  };
}
