{
  config,
  pkgs,
  ...
}: let
  wezterm_config_path = "${config.home.homeDirectory}/dotfiles/wezterm/.config/wezterm";
  nushell_config_path = "${config.home.homeDirectory}/dotfiles/nu/.config/nushell";
  foot_config_path = "${config.home.homeDirectory}/dotfiles/foot/.config/foot";
in {
  # 注意修改这里的用户名与用户目录
  home.username = "zjw";
  home.homeDirectory = "/home/zjw";

  xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink wezterm_config_path;
  xdg.configFile."nushell".source = config.lib.file.mkOutOfStoreSymlink nushell_config_path;
  xdg.configFile."foot".source = config.lib.file.mkOutOfStoreSymlink foot_config_path;

  home.packages = with pkgs; [
    fish
    zoxide
    carapace
    eza
    yazi
    foot
    wezterm
    atuin
  ];
}
