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

  # NOTE: VST and LV2 Plugin search paths are
  # in env variables:
  # - `$LV2_PATH` and
  # - `$VST3_PATH`

  # NOTE: Latency: I use pipewire's jack implementation
  # Use `pw-top` to see the settings, QUANT are the samples.
  # Force 128 samples with.
  # `pw-metadata -n settings 0 clock.force-quantum 128`
  # Set starting values for the clock quantum and rate.
  services.pipewire = {
    # --- Graph-wide clock (PipeWire)
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 48000 ]; # don't switch to 44.1k behind your back
        "default.clock.quantum" = 128;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 1024;
      };
    };

    # --- M-Track device settings (WirePlumber)
    # wireplumber.extraConfig."51-m-audio-m-track" = {
    #   "monitor.alsa.rules" = [
    #     {
    #       matches = [
    #         { "node.name" = "~alsa.*M-Audio.*"; }
    #         { "node.name" = "~alsa.*M-Audio.*"; }
    #       ];
    #       actions.update-props = {
    #         "audio.rate" = 48000;
    #         "api.alsa.period-size" = 128; # ALSA buffer on the device itself
    #         "api.alsa.headroom" = 0; # raise (e.g. 128, 256) if ERR keeps climbing in pw-top
    #         "session.suspend-timeout-seconds" = 0; # never let the interface sleep
    #         "priority.driver" = 3000; # prefer the M-Track as the graph clock
    #         "priority.session" = 3000; # and as the default device
    #       };
    #     }
    #   ];
    # };
  };

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
