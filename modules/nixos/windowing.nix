{
  config,
  pkgs,
  pkgsStable,
  ...
}:
{
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
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true; # Bridge to Wayland API for X11 apps.
  # };
  #
  #
  # # Handle desktop interaction.
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  # };
  #
  # # Useful packages.
  # environment.systemPackages = with pkgs; [
  #   hyprland
  #
  #   (
  #     waybar.overrideAttrs (oldAttrs: {
  #       mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
  #     })
  #   )
  #
  #   dunst # Notification daemon (needs libnotify).
  #   libnotify
  #
  #   swww # Wallpaper daemon for wayland.
  #
  #   rofi-wayland # Window switcher.
  #   networkmanagerapplet # Networkmanager applet.
  #
  #   grim # Screenshot in Wayland.
  #   slurp # Wayland region selector.
  #   playerctl # Player control in waybar.
  # ];
  #
  # # Sessions variables
  # environment.sessionVariables = {
  #   # Clutter based apps.
  #   CLUTTER_BACKEND = "wayland";
  #   # Hint electron apps to use wayland.
  #   NIXOS_OZONE_WL = "1";
  #
  #   WLR_NO_HARDWARE_CURSORS = "1";
  #   WLR_RENDERER_ALLOW_SOFTWARE = "1";
  #   WLR_RENDERER = "vulkan";
  #
  #   XDG_CURRENT_DESKTOP = "Hyprland";
  #   XDG_SESSION_DESKTOP = "Hyprland";
  #   XDG_SESSION_TYPE = "wayland";
  # };
  # ===========================================================================

  # Sway Window Manager
  # ===========================================================================
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly

    extraPackages = with pkgs; [
      power-profiles-daemon

      swaylock-effects # Swaylock but with more effects.
      swayidle
      swaynotificationcenter
      i3-back
      libnotify

      way-displays # Manage your displays.

      xdg-utils
      flashfocus # Flash focus animations in sway.
      copyq # Clipboard manager.
      qalculate-gtk # Calculator menu.

      wl-clipboard # Wayland clipboard.
      wf-recorder # Wayland screen recorder.
      grim # Screenshot tool in Wayland.
      slurp # Wayland region selector.
      sway-contrib.grimshot # Main screenshot tool.
      swappy # Edit tool for screenshots.
      gcolor3 # Colorwheel picker.
      hyprpicker # Colorpicker on screen.

      rofi # Application Launcher for waybar.
      rofimoji
      rofi-power-menu
      rofi-bluetooth
      rofi-systemd

      avizo # Nice brightnessctl and audio volume visualization for wayland.
      brightnessctl # Brightness control in waybar.
      playerctl # Player control in waybar.

      waybar # The top bar.
    ];

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway

      if command -v gnome-keyring-daemon; then
        eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh);
        export SSH_AUTH_SOCK;
      fi
    '';
  };

  environment.variables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };
  # ===========================================================================

  # To make screencasting work in Chrome and other Apps communicating
  # over DBus.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
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
    (nerdfonts.override {
      fonts = [
        "Noto"
        "JetBrainsMono"
      ];
    })
  ];
}
