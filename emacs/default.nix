
{
  config,
  pkgs,
  ...
}: let
  emacs_config_path = "${config.home.homeDirectory}/dotfiles/emacs/.config/emacs";
in {
  # 注意修改这里的用户名与用户目录

  xdg.configFile."emacs".source = config.lib.file.mkOutOfStoreSymlink emacs_config_path;

}
