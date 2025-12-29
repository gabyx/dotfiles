{ lib, config, ... }:
{
  # Check kernel parameters:
  # `zgrep -e "CONFIG_IRQ_FORCED_THREADING=y" -e "CONFIG_PREEMPT_RT=y" /proc/config.gz`
  musnix = {
    enable = true;

    kernel.realtime = true;
    das_watchdog.enable = true;
    rtcqs.enable = true;

    rtirq = {
      # highList = "snd_hrtimer";
      resetAll = 1;
      prioLow = 0;
      enable = false;
      nameList = "rtc0 snd";
    };
  };

  # The musnix sets only PAM loginLimits but this is not used when starting with
  # sway/(hyprland?) which starts over systemd which override PAM limits?.
  systemd.user.extraConfig = lib.mkIf config.settings.windowing.isTiling ''
    DefaultLimitRTPRIO=99
    DefaultLimitMEMLOCK=infinity
  '';
}
