let
  rootDisk = "/dev/disk/by-id/nvme-Samsung_SSD_990_EVO_2TB_S7GDNS0WC06836F";
in
{
  disko.enableConfig = false; # We have not reformatted the disk yet and if `true` disko wants to maintain that what is in filesystem.

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = rootDisk;

        content = {
          type = "gpt";
          partitions = {

            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "fat32";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";

                # disable settings.keyFile if you want to use interactive password entry
                #passwordFile = "/tmp/secret.key"; # Interactive
                # settings = {
                #   allowDiscards = true;
                #   keyFile = "/tmp/secret.key";
                # };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];

                content = {
                  label = "SYSTEM";

                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/var/log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      # Creates a file `swapfile`.
                      swap.swapfile.size = "75G";
                      mountOptions = [
                        "noatime"
                        "nodatacow"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
