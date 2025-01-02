{
  config,
  pkgs,
  ...
}:
let
  settings = config.settings;
in
{
  imports = [ ./user-icon.nix ];

  ### User Settings ==========================================================
  users = {
    users.${settings.user.name} = {
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

      # Authorized keys to access the machine if openssh is enabled.
      openssh.authorizedKeys.keyFiles = settings.user.opensshAuthKeyFiles;
    };

  };
  # ===========================================================================
}
