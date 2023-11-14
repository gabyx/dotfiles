{
  config,
  pkgs,
  ...
}: {
  ### Fonts ================================================================
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;

    packages = with pkgs; [
      corefonts
      ubuntu_font_family
      fira
      meslo-lgs-nf
      noto-fonts
      eb-garamond
      zilla-slab
      google-fonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "SourceCodePro"];})
    ];
  };

  environment.systemPackages = with pkgs; [
    font-manager
  ];

  # ===========================================================================
}
