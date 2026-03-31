{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS 官方软件源，这里使用 nixos-25.11 分支
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    rime-config = {
      url = "github:luckyydoge/rime";
      flake = false;
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      # 建议让它跟随你的 nixpkgs，节省空间并减少 glibc 版本冲突
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-25.11";
    # disko = {
    #   url = "github:nix-community/disko";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    zen-browser,
    nixos-wsl,
    # noctalia-shell,
    ...
  } @ inputs: {
    nixosConfigurations = {
      zjw-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          # 这里导入之前我们使用的 configuration.nix，
          # 这样旧的配置文件仍然能生效
          ./system/configuration-base.nix
          ./system/xingyao14/configuration.nix
          ./noctalia.nix

          # disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            # nixpkgs.config.allowUnfreePredicate = pkg:
            #   builtins.elem (lib.getName pkg) [
            #     "idea"
            #   ];
            nixpkgs.config.allowUnfree = true;
          }

          # noctalia-shell.homeModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # 这里的 ryan 也得替换成你的用户名
            # 这里的 import 函数在前面 Nix 语法中介绍过了，不再赘述
            home-manager.users.zjw =
              import
              ./home.nix;

            # 使用 home-manager.extraSpecialArgs 自定义传递给 ./home.nix 的参数
            # 取消注释下面这一行，就可以在 home.nix 中使用 flake 的所有 inputs 参数了
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
      };

      zjw-wsl = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          # 这里导入之前我们使用的 configuration.nix，
          # 这样旧的配置文件仍然能生效
          ./system/configuration-base.nix
          ./system/wsl.nix
          ./noctalia.nix
          nixos-wsl.nixosModules.default
          # disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            # nixpkgs.config.allowUnfreePredicate = pkg:
            #   builtins.elem (lib.getName pkg) [
            #     "idea"
            #   ];
            nixpkgs.config.allowUnfree = true;
          }

          # noctalia-shell.homeModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # 这里的 ryan 也得替换成你的用户名
            # 这里的 import 函数在前面 Nix 语法中介绍过了，不再赘述
            home-manager.users.zjw =
              import
              ./home.nix;

            # 使用 home-manager.extraSpecialArgs 自定义传递给 ./home.nix 的参数
            # 取消注释下面这一行，就可以在 home.nix 中使用 flake 的所有 inputs 参数了
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
      };

      installer = nixpkgs.lib.nixosSystem {
        # system = "x86_64-linux"; # 或者是你的目标平台
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          # 1. 导入 ISO 核心模块 (必须)
          # "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

          # 2. 导入你现有的 configuration.nix (复用你的软件列表)
          # ./system/configuration.nix
          ./iso.nix
        ];
      };
    };
  };
}
