{
  config,
  pkgs,
  ...
}: let
  niri_config_path = "${config.home.homeDirectory}/dotfiles/niri/.config/niri";
  mako_config_path = "${config.home.homeDirectory}/dotfiles/mako/.config/mako";
in {
  # 注意修改这里的用户名与用户目录
  home.username = "zjw";
  home.homeDirectory = "/home/zjw";

  # xdg.configFile."niri".source = config.lib.file.mkOutOfStoreSymlink niri_config_path;
  xdg.configFile."mako".source = config.lib.file.mkOutOfStoreSymlink mako_config_path;
  xdg.configFile."niri".source = config.lib.file.mkOutOfStoreSymlink niri_config_path;

  home.packages = with pkgs; [
    fuzzel
    mako
    libnotify
    waybar
  ];

  services = {
    udiskie = {
      enable = true;
      tray = "auto"; # 或者 "always"
      notify = true;
    };
    mako = {
      enable = true;
    };
  };
}
