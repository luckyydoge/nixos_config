{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            swap = {
              size = "1G"; # 必须大于或等于你的 RAM 大小才能稳定休眠
              content = {
                type = "swap";
                resumeDevice = true; # 告诉 disko 这是用来休眠唤醒的设备
              };
            };

            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "/rootfs" = {
                    mountpoint = "/";
                  };
                  # Subvolume name is the same as the mountpoint
                  "/home" = {
                    mountOptions = ["compress=zstd"];
                    mountpoint = "/home";
                  };
                  # Parent is not mounted so the mountpoint must be set
                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/nix";
                  };
                };

                mountpoint = "/partition-root";
              };
            };
          };
        };
      };
      secondary = {
        type = "disk";
        device = "/dev/vdb"; # 确保这是你的第二块硬盘路径
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                # 关键点：将新分区也定义为 btrfs，但不重复定义子卷
                # 注意：在某些 Disko 版本中，如果你想让它们自动合并，
                # 手动执行一次 `btrfs device add` 后，Disko 会通过挂载点自动识别。
              };
            };
          };
        };
      };
    };
  };
}
