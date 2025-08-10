{
  config,
  lib,
  pkgs,
  ...
}:
let
  windowMgr = config.settings.windowing.manager;

  waylandEnvs = ''
    export XDG_SESSION_TYPE=wayland

    export NIXOS_OZONE_WL=1
    export GDK_BACKEND=wayland,x11
    export CLUTTER_BACKEND=wayland

    export SDL_VIDEODRIVER=wayland

    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland;xcb
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export _JAVA_AWT_WM_NONREPARENTING=1
  '';

  startKeyring = ''
    export GNOME_KEYRING_CONTROL=/run/user/$UID/keyring
    export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh
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
  assertions = [
    {
      assertion = (windowMgr == "sway" || windowMgr == "hyprland");
      message = "Incorrect window manager name.";
    }
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = true;

  # Display Manager ===========================================================
  services.displayManager = {
    autoLogin.enable = false;
    autoLogin.user = "nixos";
  };

  services.xserver.displayManager = {
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

  # Desktop Manager ===========================================================
  # They interfere with the Window Manager.
  # services.xserver.desktopManager.xfce.enable = true;
  # ===========================================================================

  # Hyprland Window Manager ===================================================
  programs.hyprland = lib.mkIf (windowMgr == "hyprland") {
    enable = true;
    xwayland.enable = true; # Bridge to Wayland API for X11 apps.
    # TODO: Make homemanager config.
  };
  # ===========================================================================

  # Sway Window Manager
  # ===========================================================================
  programs.sway = lib.mkIf (windowMgr == "sway") {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly

    extraPackages = [
      pkgs.i3-back # last workspace
    ] ++ commonPkgs;

    extraSessionCommands =
      waylandEnvs
      + ''
        export XDG_SESSION_DESKTOP=sway
        export XDG_CURRENT_DESKTOP=sway
      ''
      + startKeyring;
  };
  # ===========================================================================

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

  security.polkit.enable = true; # https://discourse.nixos.org/t/sway-does-not-start/22354/5

  fonts.packages = with pkgs; [
    # Waybar
    font-awesome
    cantarell-fonts
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
  ];
}
