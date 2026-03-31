{
  config,
  pkgs,
  ...
}: let
  nvim_config_path = "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";
in {
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvim_config_path;

  home.packages = with pkgs; [
    neovim
    # Rust
    rust-analyzer

    pyright
    python313Packages.debugpy

    # Typst (tinymist)
    tinymist
    typst

    # Lua
    lua-language-server
    stylua

    # Markdown
    markdownlint-cli2
  ];
}
