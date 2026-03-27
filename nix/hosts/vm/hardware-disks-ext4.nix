{ ... }:
{
  disko.devices = {
    disk = {
      root = {
        # The VM image settings.
        imageName = "root";
        imageSize = "20G";

        device = "/dev/vda";
        type = "disk";

        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "128M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
