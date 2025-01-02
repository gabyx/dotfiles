{
  config,
  ...
}:
let
  userName = config.settings.user.name;
  icon = config.settings.user.icon;
in
{
  systemd.services.place-user-icon = {
    before = [ "display-manager.service" ];
    wantedBy = [ "display-manager.service" ];

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
    };

    script = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      pic="${icon}"

      if [ ! -f "$pic" ]; then
        echo "User image not existing in '$pic' -> Skip setup."
        exit 0
      fi

      echo "User image existing in '$pic' -> Setup."
      cp "$pic" /var/lib/AccountsService/icons/${userName}
      echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${userName}\n" > /var/lib/AccountsService/users/${userName}

      chown root:root /var/lib/AccountsService/users/${userName}
      chmod 0600 /var/lib/AccountsService/users/${userName}

      chown root:root /var/lib/AccountsService/icons/${userName}
      chmod 0444 /var/lib/AccountsService/icons/${userName}
    '';
  };
}
