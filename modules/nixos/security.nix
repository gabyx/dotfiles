{
  config,
  pkgs,
  ...
}:
{
  security = {
    rtkit.enable = true;

    apparmor = {
      enable = true;
      packages = with pkgs; [ apparmor-profiles ];
    };

    pam.services = {
      login.enableGnomeKeyring = true;

      # For SSH logins enable the Google Authenticator login.
      sshd.googleAuthenticator.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    google-authenticator # For SSH logins.
  ];

  services = {
    dbus.apparmor = "enabled";
  };
}
