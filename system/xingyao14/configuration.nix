{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./boot-grub.nix
  ];
  # --- 服务配置 ---
  services = {
    # Snapper: 快照自动管理
    snapper = {
      configs = {
        root = {
          SUBVOLUME = "/";
          ALLOW_USERS = ["zjw"];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = "24";
          TIMELINE_LIMIT_DAILY = "7";
          TIMELINE_LIMIT_WEEKLY = "0";
          TIMELINE_LIMIT_MONTHLY = "0";
          TIMELINE_LIMIT_YEARLY = "0";
        };
        home = {
          SUBVOLUME = "/home";
          ALLOW_USERS = ["zjw"];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = "24";
          TIMELINE_LIMIT_DAILY = "7";
          TIMELINE_LIMIT_WEEKLY = "0";
          TIMELINE_LIMIT_MONTHLY = "0";
          TIMELINE_LIMIT_YEARLY = "0";
        };
      };
    };

    # Udev 规则 (放在 services 下，确保 Kanata 或其他硬件访问权限)
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e491", MODE="0666", TAG+="uaccess"
    '';

    # Kanata: 键盘重映射服务
    kanata = {
      enable = true;
      keyboards = {
        default = {
          # 确保路径指向你之前修冲突的那个 config.kbd
          config = builtins.readFile ../../kanata/config.kbd;
          extraDefCfg = "process-unmapped-keys yes";
        };
      };
    };
  };

  # --- 用户配置 ---
  users.users.zjw = {
    isNormalUser = true;
    # 加上 uinput 组，这对于 Kanata 访问虚拟键盘输入非常重要
    extraGroups = ["wheel" "input" "video" "podman" "audio" "uinput"];
    packages = with pkgs; [];
  };

  # --- 虚拟化配置 (Podman) ---
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
