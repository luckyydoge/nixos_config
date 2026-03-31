{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.file.".local/share/fcitx5/rime" = {
    # 这里的 inputs.rime-config 就指向了你 GitHub 仓库下载后的路径
    source = inputs.rime-config;

    # 必须设置为 true
    # 这样 Home Manager 会在 ~/.local/share/fcitx5/rime 创建真实的目录
    # 并把仓库里的文件一个个软链接进去，允许 Rime 在里面创建 build 缓存文件夹
    recursive = true;
  };

  # 确保安装了 fcitx5-rime
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true; # 专门针对 Wayland 环境
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
      qt6Packages.fcitx5-configtool
      qt6Packages.fcitx5-chinese-addons
    ];
  };
}
