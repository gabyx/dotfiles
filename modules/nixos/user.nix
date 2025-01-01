{
  config,
  pkgs,
  ...
}:
let
  settings = config.settings;
  userName = settings.user.name;
in
{
  ### User Settings ==========================================================
  users = {
    users.${userName} = {
      shell = pkgs.zsh;

      useDefaultShell = false;

      initialPassword = "nixos";
      isNormalUser = true;

      extraGroups = [
        "wheel"
        "disk"
        "libvirtd"
        "audio"
        "video"
        "input"
        "messagebus"
        "systemd-journal"
        "networkmanager"
        "network"
        "davfs2"
        "dialout" # For bazecor and the Dygma keyboard.
      ];

      # Extent the user `uid/gid` ranges to make podman work better.
      # This is for using https://gitlab.com/qontainers/pipglr
      subUidRanges = [
        {
          startUid = 100000;
          count = 65539;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65539;
        }
      ];

      openssh.authorizedKeys.keyFiles = [ ../../config/private_dot_ssh/gabyx_ed25519.pub ];
    };

  };

  # Place a user image if there is a `.face` (needs to be PNG) in the
  # user folder.
  system.activationScripts.script.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    pic="${config.settings.user.profilePicture}"

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
  # ===========================================================================
}
