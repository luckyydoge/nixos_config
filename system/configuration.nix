# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./btrfs-subvolumes.nix
    # "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
  ];

  nix = {
    settings = {
      substituters = ["https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store"];
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev"; # or "nodev" for efi only
  };
  boot.kernelParams = [
    # 正确的 SOF 强制开关
    "snd_intel_dspcfg.dsp_driver=3" # 尝试强制使用 SOF
    "snd_amd_asoc.allow_acp70=1"

    # 彻底阻止传统驱动加载，防止它抢占设备
    "module_blacklist=snd_pci_acp6x,snd_pci_acp5x,snd_rn_pci_acp3x,snd_acp_pci,snd_acp_pdm_mach"

    # 针对 14 寸笔记本 DMIC 的偏移修正
    "snd_soc_dmic.force_dmic_2ch=1"
  ];

  # 尝试屏蔽掉那个“抢位”但干活不成的基础 PDM 驱动，让 SOF 接管
  boot.blacklistedKernelModules = ["snd_pci_acp6x" "snd_pci_acp5x" "snd_rn_pci_acp3x"];
  boot.supportedFilesystems = ["ntfs" "exfat"];
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelModules = [ "snd_sof_amd_acp70" ];

  networking = {
    hostName = "zjw-nixos"; # Define your hostname.

    # Configure network connections interactively with nmcli or nmtui.
    networkmanager.enable = true;
  };
  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk]; # 或者 pkgs.xdg-desktop-portal-wlr
    config.common.default = "*"; # 强制使用默认 portal
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  systemd.user.services = {
    fcitx5-daemon = {
      description = "Fcitx5 input method editor";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        # 模仿你手动执行的参数
        # -r 确保替换掉系统可能产生的僵尸进程
        ExecStart = "${pkgs.fcitx5}/bin/fcitx5 -r";
        Restart = "on-failure";
      };
    };
    polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  # Enable sound.
  services = {
    snapper = {
      configs = {
        root = {
          SUBVOLUME = "/";
          # 权限设置：注意现在是直接作为属性，且值是字符串
          ALLOW_USERS = ["zjw"];
          # 策略设置：现在直接写在配置块里，通常建议全大写以匹配 snapper 原生参数名
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
    flatpak.enable = true;
    udisks2.enable = true;
    dbus.packages = [pkgs.fcitx5];
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber.enable = true;
      extraConfig.pipewire."99-amd-strix-quality" = {
        "context.properties" = {
          # 强制全局采样率为 48000，解决 Strix Point 的时钟抖动
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [48000];
        };
      };
    };
    v2raya.enable = true;
    displayManager.ly = {
      enable = true;
    };
    power-profiles-daemon = {
      enable = true;
    };
    upower = {
      enable = true;
    };
    # tlp = {
    #   enable = true;
    #   settings = {
    #     # 第一组：CPU 频率缩放调速器
    #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
    #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    #
    #     # 第二组：CPU 能量性能偏好 (EPP)
    #     # 注：这通常适用于支持 intel_pstate 或 amd_pstate 驱动的现代 CPU
    #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    #     CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    #
    #     # 可选：如果你想更激进地省电，可以在电池模式下禁用睿频
    #     # CPU_BOOST_ON_BAT = 0;
    #   };
    # };
    kanata = {
      enable = true;
      keyboards = {
        default = {
          config = builtins.readFile ../kanata/config.kbd;
          extraDefCfg = "process-unmapped-keys yes";
        };
      };
    };
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e491", MODE="0666", TAG+="uaccess"
    '';
  };

  programs = {
    niri = {
      enable = true;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        fuse3
        icu
        nss
        openssl
        curl
        expat
        # 如果 rust-analyzer 报错，通常需要这个
        libgcc
      ];
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zjw = {
    isNormalUser = true;
    extraGroups = ["wheel" "input" "video" "podman" "audio"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };
  virtualisation.podman = {
    enable = true;
    # 这一行非常关键：它会创建一个符号链接，让所有调用 docker 命令的操作自动转向 podman
    dockerCompat = true;
    # 允许容器通过主机名互相访问
    defaultNetwork.settings.dns_enabled = true;
  };
  # programs.firefox.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    xray
    v2raya

    niri
    xwayland
    xwayland-satellite

    bottom
    btop
    duf
    dust
    ripgrep
    fd
    bat
    yazi
    nushell
    jujutsu
    _7zz
    nh
    just

    alsa-utils
    pavucontrol
    sof-firmware
    pciutils
    alsa-ucm-conf

    btrfs-assistant
    polkit_gnome

    nerd-fonts.iosevka-term
    stdenv.cc
    brightnessctl
    alejandra
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka-term
    nerd-fonts.noto
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    wqy_zenhei # 文泉驿正黑
    wqy_microhei # 文泉驿微米黑
    # google-fonts
    ibm-plex
    hanazono
    lxgw-wenkai

    sarasa-gothic
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      # 在所有分类中，手动将 SC (Simplified Chinese) 放在最前面
      # sansSerif = ["Noto Sans CJK SC"];
      serif = ["Noto Serif CJK SC"];
      # monospace = ["Noto Sans Mono CJK SC"];
# 界面用 UI 版
    sansSerif = ["Sarasa UI SC" "Noto Sans CJK SC"];
    # 写代码用 Mono 或 Mono Slab
    monospace = ["Sarasa Mono SC" "Noto Sans Mono CJK SC"];
    };
  };
  environment.variables = {
    # GTK_IM_MODULE = "fcitx";
    # QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    # SDL_IM_MODULE = "fcitx";
  };
  environment.shells = [
    pkgs.nushell
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
