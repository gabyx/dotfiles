{
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
    };
  };

  environment.systemPackages = with pkgs; [
    vulnix # Security scanning of Nix derivations.
  ];

  services = {
    dbus.apparmor = "enabled";
  };
}
