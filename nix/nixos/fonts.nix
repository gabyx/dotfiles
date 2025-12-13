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

    packages = with pkgs; [
      corefonts
      ubuntu-classic

      fira

      noto-fonts
      noto-fonts-color-emoji

      google-fonts

      nerd-fonts.jetbrains-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.fira-code
    ];
  };

  environment.systemPackages = with pkgs; [
    font-manager
  ];

  # ===========================================================================
}
