{
  osConfig,
  pkgs,
  ...
}:
{
  ### Calendar Syncing ========================================================
  home.packages = with pkgs; [
    vdirsyncer
    davmail
  ];

  services = {
    vdirsyncer = {
      enable = true;
      frequency = "*:0/2"; # Sync every 2 minutes.
    };
    # ===========================================================================

    ### Audio Effects ===========================================================
    easyeffects = {
      enable = true;
      preset = "headset-effects.json";
      # Enable also `dconf` to take effect.
    };

    # ===========================================================================

    ### Color Shifting ==========================================================
    gammastep = {
      enable = true;
      provider = "manual";

      longitude = 8.55;
      latitude = 47.36667;

      temperature = {
        day = 5700;
        night = 4600;
      };

      tray = true;
    };
  };
  # ==========================================================================
}
