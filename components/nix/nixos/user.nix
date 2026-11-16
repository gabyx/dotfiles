{
  config,
  pkgs,
  ...
}:
let
  cfg = config.settings.user;
in
{
  imports = [ ./user-icon.nix ];

  config = {
    ### User Settings ==========================================================
    users = {
      users.${cfg.name} = {
        shell = pkgs.zsh;

        useDefaultShell = false;

        initialPassword = "nixos";
        isNormalUser = true;

        extraGroups = [
          "wheel"
          "disk"
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
        openssh.authorizedKeys.keyFiles = cfg.openssh.authKeyFiles;
      };
    };
    # ===========================================================================
  };
}
