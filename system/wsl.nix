# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  config,
  lib,
  pkgs,
  ...
}: {
  #imports = [
  # include NixOS-WSL modules
  # <nixos-wsl/modules>
  #];

  wsl.enable = true;
  wsl.interop.register = true;
  wsl.defaultUser = "zjw";

  services = {
    openssh = {
      enable = true;
      settings = {
        # 允许密码登录（方便初次连接，后期建议换成密钥）
        PasswordAuthentication = true;
        # 允许 Root 登录（可选，建议保持为 "no" 或 "prohibit-password"）
        PermitRootLogin = "no";
      };
    };
  };

  users.users.zjw = {
    isNormalUser = true;
    extraGroups = ["wheel" "input" "video" "podman" "audio" "docker"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };
  virtualisation.docker.enable = true;
  virtualisation.podman = {
    enable = true;
    # 这一行非常关键：它会创建一个符号链接，让所有调用 docker 命令的操作自动转向 podman
    # dockerCompat = true;
    # 允许容器通过主机名互相访问
    defaultNetwork.settings.dns_enabled = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
