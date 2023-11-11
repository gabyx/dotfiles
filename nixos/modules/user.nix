{
  config,
  pkgs,
  settings,
  ...
}: {
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
        "docker"
        "audio"
        "video"
        "input"
        "systemd-journal"
        "networkmanager"
        "network"
        "davfs2"
      ];
    };
  };
  # ===========================================================================
}
