{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types mkOption;
  windowMgr = config.settings.windowing.manager;

  sessionType = "wayland";
  desktopType =
    assert lib.assertMsg (
      windowMgr == "sway" || windowMgr == "hyprland"
    ) "Incorrect window manager name.";
    if windowMgr == "sway" then "sway" else "Hyprland";

  waylandEnvs = {
    XDG_SESSION_TYPE = sessionType;

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
    (builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (k: v: ''export ${k}="${builtins.toString v}";'') envs
    ));

  adjustKeyring = ''
    # Adds some more components to the gnome keyring daemon.
    export GNOME_KEYRING_CONTROL="/run/user/$UID/keyring"
    export SSH_AUTH_SOCK="/run/user/$UID/keyring/ssh"
    eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg);
  '';

  commonPkgs = with pkgs; [
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

    (if windowMgr == "sway" then sway-contrib.grimshot else hyprshot) # Main screenshot tool.

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

    # Lockscreen (works on hyperland too)
    swaylock-effects # Swaylock but with more effects.
    swayidle
    swaynotificationcenter
  ];
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
      enable = (windowMgr == "hyprland");
      xwayland.enable = true; # Bridge to Wayland API for X11 apps.
      # TODO: Make homemanager config.
    };
    # ===========================================================================

    # Sway Window Manager
    # ===========================================================================
    programs.sway = {
      enable = (windowMgr == "sway");
      xwayland.enable = true;
      wrapperFeatures.gtk = true; # so that gtk works properly

      extraPackages = [
        pkgs.i3-back # last workspace
      ]
      ++ commonPkgs;

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
        (
          if windowMgr == "sway" then pkgs.xdg-desktop-portal-wlr else config.programs.hyprland.portalPackage
        )
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
