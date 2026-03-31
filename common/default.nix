{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    btop
    bottom
    _7zz
    sysbench
    # disko
    fastfetch
    xz
    ripgrep
  ];
}
