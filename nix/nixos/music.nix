{
  inputs,
  lib,
  config,
  packages,
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
    pkgsUnstable.reaper # Music recording.

    pkgsUnstable.carla # Music plugins patchbar.
    pkgsUnstable.calf # Calf music plugins.

    pkgsUnstable.lsp-plugins # https://lsp-plug.in/?page=plugins
    pkgsUnstable.x42-plugins # x42 lv2 plugins
    pkgsUnstable.x42-avldrums
    pkgsUnstable.drumgizmo
    pkgsUnstable.sfizz # Sampler
    pkgsUnstable.sfizz-ui # Sampler UI

    # VST2/VST3 on Windows
    # pkgsUnstable.wineWow64Packages.staging
    # pkgsUnstable.yabridge
    # pkgsUnstable.yabridgectl
    # pkgsUnstable.wineWow64Packages.yabridge

    packages.tone3000-plugin
    packages.mt-powerdrumkit
  ];

  # Some user settings. # Home Manager changes, merged with the base definition above
  environment.sessionVariables = {
    WINEPREFIX = "/persist/wine";
  };

  # Check kernel parameters:
  # `zgrep -e "CONFIG_IRQ_FORCED_THREADING=y" -e "CONFIG_PREEMPT_RT=y" /proc/config.gz`
  musnix = {
    enable = true;

    kernel = {
      realtime = true;
      packages = pkgs.linuxPackages_7_2;
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

  # Probably not super good to use memory for the temp. file system.
  boot.tmp.useTmpfs = lib.mkForce false;

  # The musnix sets only PAM loginLimits but this is not used when starting with
  # sway/(hyprland?) which starts over systemd which override PAM limits?.
  systemd.user.extraConfig = lib.mkIf config.settings.windowing.isTiling ''
    DefaultLimitRTPRIO=99
    DefaultLimitMEMLOCK=infinity
  '';
}
