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
        "systemd-journal"
        "networkmanager"
        "network"
        "davfs2"
        "dialout" # For bazecor and the Dygma keyboard.
      ];

      openssh.authorizedKeys.keyFiles = [ ../../config/private_dot_ssh/gabyx_ed25519.pub ];
    };
  };
  # ===========================================================================
}
