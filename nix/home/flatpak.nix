{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  # xdg.systemDirs.data = [
  #   "$HOME/.local/share/flatpak/exports/share"
  # ];
  #
  # home.sessionPath = [
  #   "$HOME/.local/share/flatpak/exports/bin"
  # ];

  services.flatpak = {
    enable = false;

    overrides = {
      global = {
        # Force Wayland by default
        Context.sockets = [
          "wayland"
          "!x11"
          "!fallback-x11"
        ];

        Environment = {
          # Fix un-themed cursor in some Wayland apps
          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

          # Force correct theme for some GTK apps
          GTK_THEME = "Adwaita:dark";
        };
      };

      "com.visualstudio.code".Context = {
        filesystems = [
          "xdg-config/git:ro" # Expose user Git config
          "/run/current-system/sw/bin:ro" # Expose NixOS managed software
        ];
        sockets = [
          "gpg-agent" # Expose GPG agent
          "pcsc" # Expose smart cards (i.e. YubiKey)
        ];
      };
    };

    uninstallUnmanaged = true;

    update = {
      auto = {
        enable = true;
        onCalendar = "weekly"; # Default value
      };
    };

    packages = [
      {
        appId = "org.mozilla.firefox";
      }
      {
        appId = "com.brave.Browser";
      }
      {
        appId = "com.visualstudio.code";
      }
      {
        appId = "com.slack.Slack";
      }
    ];
  };
}
