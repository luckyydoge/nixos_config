# 默认列出所有命令
default:
    @just --list

# 切换 NixOS 配置
switch-legacy:
    sudo nixos-rebuild switch --option substituters https://mirrors.ustc.edu.cn/nix-channels/store

# 切换flake
switch:
	sudo nixos-rebuild switch --flake .#zjw-nixos

# 安装系统 (示例参数化)
install host="zjw-nixos":
    sudo nixos-install --flake .#{{host}} --option substituters https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store --verbose --show-trace

# 构建 ISO 镜像
build-iso:
    nixos-rebuild build-image --flake .#installer --image-variant iso-installer