{
  lib,
  pkgs,
  ...
}:
let
  toml = pkgs.formats.toml { };

  # containers storage settings.
  # Use fuse-overlayfs instead of kernel overlay2.
  storage-settings = {
    storage = {
      driver = "btrfs";
      # options.overlay = {
      #   # mount_program = lib.getExe pkgs.fuse-overlayfs;
      #   # mountopt = "nodev,fsync=0";
      #   # force_mask = "shared";
      # };
    };
  };
in
{
  xdg.configFile."containers/storage.conf".source = toml.generate "storage.conf" storage-settings;
}
