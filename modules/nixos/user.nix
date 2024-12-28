{
  config,
  pkgs,
  ...
}:
{
  ### User Settings ==========================================================
  users = {
    users.${config.settings.user.name} = {
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
  # ===========================================================================
}
