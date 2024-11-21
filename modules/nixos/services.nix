{
  config,
  pkgs,
  ...
}:
{
  ### Services ================================================================
  services = {
    # TODO: Needs goeclue setup.
    # localtimed.enable = true;

    # UDev settings.
    udev.packages = [
      pkgs.headsetcontrol
      pkgs.bazecor
    ];

    # Dbus settings.
    dbus = {
      enable = true;
      # Choosing `broker` here uses
      # the new dbus implementation
      # which makes systemd units.
      implementation = "broker";
    };

    upower.enable = true;
    locate.enable = true;

    # Keyring Service
    gnome.gnome-keyring.enable = true;

    # For `udisksctl power-off` etc.
    udisks2.enable = true;

    gvfs.enable = true; # Mount, trash, and other functionalities.
    tumbler.enable = true; # Thumbnailing DBus service.

    # services.xrdp.enable = true;
    # services.xrdp.defaultWindowManager = "startplasma-x11";
    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    openssh = {
      enable = false;
      ports = [ 50022 ];
      settings = {
        PermitRootLogin = "no";
        AllowUsers = [ config.settings.user.name ];
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
      };
    };

    gnome.evolution-data-server.enable = true;

    # Optional to use google/nextcloud calendar
    gnome.gnome-online-accounts.enable = true;

    davmail = {
      enable = true;
      url = "https://mail.ethz.ch/EWS/Exchange.asmx";
    };
  };

  environment.systemPackages = with pkgs; [
    # Only for online accounts.
    gnome-control-center
  ];

  programs.dconf.enable = true;

  # ===========================================================================
}
