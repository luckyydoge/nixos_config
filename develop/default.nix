{
  config,
  pkgs,
  ...
}: {
  # 注意修改这里的用户名与用户目录

  home.packages = with pkgs; [
    podman-compose
    (jetbrains.idea.override
      {
        vmopts = ''
          -Dawt.toolkit.name=WLToolkit
          -D_JAVA_AWT_WM_NONREPARENTING=1
        '';
      })
  ];
}
