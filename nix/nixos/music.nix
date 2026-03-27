{
  inputs,
  lib,
  config,
  pkgs,
  pkgsUnstable,
  ...
}:
{
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  environment.systemPackages = [
    pkgsUnstable.ardour # Music recording.
    pkgsUnstable.calf # Calf music plugins.
  ];

  # Check kernel parameters:
  # `zgrep -e "CONFIG_IRQ_FORCED_THREADING=y" -e "CONFIG_PREEMPT_RT=y" /proc/config.gz`
  musnix = {
    enable = true;

    kernel = {
      realtime = true;
      packages = pkgs.linuxPackages-rt_latest;
    };
    das_watchdog.enable = true;

    # Run this tool to check if the system has bottlenecks when using
    # Linux and audio.
    rtcqs.enable = true;

    # Realtime interrupt queue.
    rtirq = {
      enable = true;
    };
  };

  # The musnix sets only PAM loginLimits but this is not used when starting with
  # sway/(hyprland?) which starts over systemd which override PAM limits?.
  systemd.user.extraConfig = lib.mkIf config.settings.windowing.isTiling ''
    DefaultLimitRTPRIO=99
    DefaultLimitMEMLOCK=infinity
  '';
}
