{
  disko.devices.disk = {
    "nvme" = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-ASint_AS806_512GB_806512GHLSD25C030510";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                  ];
                };
                "store" = {
                  mountpoint = "/nix/store";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
    "btrf-raid-a" = {
      type = "disk";
      device = "/dev/disk/by-id/ata-ST8000VN002-2ZM188_WPV2J4FL";
      content = {
        type = "gpt";
        partitions."main" = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              "--force"
              "--data raid1" # mirroring
              "--metadata raid1"
              "/dev/disk/by-id/ata-ST8000VN002-2ZM188_WPV218JM"
            ];
            subvolumes = {
              "backups" = {
                mountpoint = "/data/backups";
                mountOptions = [
                  "compress=zstd:20" # high compression for backups
                ];
              };
              "media" = {
                mountpoint = "/data/media";
                mountOptions = [
                  "compress=zstd:2" # fast compression for media
                ];
              };
            };
          };
        };
      };
    };
  };
}