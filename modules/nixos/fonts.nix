{
  config,
  pkgs,
  ...
}: {
  ### Fonts ================================================================
  fonts = {
    fontconfig = {
      enable = true;
      allowBitmaps = false;
      defaultFonts = {
        serif = ["NotoSerif Nerd Font"];
        sansSerif = ["Noto Sans Nerd Font"];
        monospace = ["JetBrainsMono Nerd Font"];
        emoji = ["Noto Emoji"];
      };
    };
    fontDir.enable = true;

    packages = with pkgs; [
      corefonts
      ubuntu_font_family
      fira
      meslo-lgs-nf
      noto-fonts
      noto-fonts-emoji
      emojione
      google-fonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "SourceCodePro"];})
    ];
  };

  environment.systemPackages = with pkgs; [
    font-manager
  ];

  # ===========================================================================
}
