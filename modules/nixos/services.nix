{
  config,
  pkgs,
  ...
}: {
  ### Services ================================================================
  services = {
    dbus.enable = true;
    upower.enable = true;
    locate.enable = true;

    # For `udisksctl power-off` etc.
    udisks2.enable = true;

    # Keyring Service
    gnome.gnome-keyring.enable = true;

    gvfs.enable = true; # Mount, trash, and other functionalities.
    tumbler.enable = true; # Thumbnailing DBus service.

    # services.xrdp.enable = true;
    # services.xrdp.defaultWindowManager = "startplasma-x11";
    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      ports = [50022];
      settings = {
        PermitRootLogin = "no";
        AllowUsers = [config.settings.user.name];
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
      };
    };
  };
  # ===========================================================================
}
