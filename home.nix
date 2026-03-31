{
  config,
  pkgs,
  inputs,
  ...
}: let
in {
  imports = [
    ./cli
    ./niri
    ./common
    ./rime
    ./nvim
    ./develop
    ./emacs
  ];
  # 注意修改这里的用户名与用户目录
  home.username = "zjw";
  home.homeDirectory = "/home/zjw";

  home.packages = with pkgs; [
    neovim
    jujutsu
    qutebrowser
    zathura
    zathuraPkgs.zathura_pdf_mupdf
    onlyoffice-desktopeditors

    google-chrome

    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  services = {
    emacs = {
      enable = true;
    };
  };
  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages = epkgs:
        with epkgs; [
          # 使用 override 强行注入 librime，Nix 会自动处理编译环境
          (rime.override {librime = pkgs.librime;})
          nix-ts-mode
          envrc
        ];
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };

  # git 相关配置
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "zjw";
        email = "zjw000107@gmail.com";
      };
    };
  };
  programs.home-manager.enable = true;
  # programs.noctalia-shell = {
  #   enable = true;
  # };

  # 启用 starship，这是一个漂亮的 shell 提示符
  # programs.starship = {
  #   enable = true;
  #   # 自定义配置
  #   settings = {
  #     add_newline = false;
  #     aws.disabled = true;
  #     gcloud.disabled = true;
  #     line_break.disabled = true;
  #   };
  # };
  #
  # # alacritty - 一个跨平台终端，带 gpu 加速功能
  # programs.alacritty = {
  #   enable = true;
  #   # 自定义配置
  #   settings = {
  #     env.term = "xterm-256color";
  #     font = {
  #       size = 12;
  #       draw_bold_text_with_bright_colors = true;
  #     };
  #     scrolling.multiplier = 5;
  #     selection.save_to_clipboard = true;
  #   };
  # };
  #
  # programs.bash = {
  #   enable = true;
  #   enablecompletion = true;
  #   # todo 在这里添加你的自定义 bashrc 内容
  #   bashrcextra = ''
  #     export path="$path:$home/bin:$home/.local/bin:$home/go/bin"
  #   '';
  #
  #   # todo 设置一些别名方便使用，你可以根据自己的需要进行增删
  #   shellaliases = {
  #     k = "kubectl";
  #     urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
  #     urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  #   };
  # };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
