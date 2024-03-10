{
  config,
  pkgs,
  ...
}: {
  security = {
    rtkit.enable = true;

    apparmor = {
      enable = true;
      packages = with pkgs; [
        apparmor-profiles
      ];
    };

    pam.services = {
      login.enableGnomeKeyring = true;

      # For SSH logins enable the Google Authenticator login.
      sshd.googleAuthenticator.enable = true;
    };
  };

  packages = with pkgs; [
    google-authenticator
  ];

  services = {
    dbus.apparmor = "enabled";
    openssh = {
      settings = {PermitRootLogin = "no";};
    };
  };
}
