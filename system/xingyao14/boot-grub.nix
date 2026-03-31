{
  config,
  pkgs,
  ...
}: {
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    # "nodev" 适用于 UEFI 模式，GRUB 会自动探测 EFI 分区
    device = "nodev";
  };
}
