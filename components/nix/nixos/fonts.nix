{
  pkgs,
  ...
}:
{
  ### Fonts ================================================================
  fonts = {
    fontconfig = {
      enable = true;
      allowBitmaps = false;
      defaultFonts = {
        serif = [ "NotoSerif Nerd Font" ];
        sansSerif = [ "NotoSans Nerd Font" ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "DejaVuSansM Nerd Font Mono"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
    fontDir.enable = true;

    packages = [
      pkgs.corefonts
      pkgs.ubuntu-classic
      pkgs.fira
      pkgs.noto-fonts
      pkgs.noto-fonts-color-emoji
      pkgs.google-fonts
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.dejavu-sans-mono
      pkgs.nerd-fonts.sauce-code-pro
      pkgs.nerd-fonts.fira-code
    ];
  };

  environment.systemPackages = [
    pkgs.font-manager
  ];

  # ===========================================================================
}
