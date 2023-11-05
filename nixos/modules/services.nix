{ config, pkgs, ... }:

{
  ### Services ================================================================
  services = {
    dbus.enable = true;
    upower.enable = true;

    # Keyring Service
    gnome.gnome-keyring.enable = true;

    # services.xrdp.enable = true;
    # services.xrdp.defaultWindowManager = "startplasma-x11";
    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
      };
    };
  };
  # ===========================================================================
}
