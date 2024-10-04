{
  config,
  pkgs,
  lib,
  ...
}:
{
  ### Sound Settings ==========================================================
  security.rtkit.enable = true;

  # Disable Pulseaudio because Pipewire is used.
  hardware.pulseaudio.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [ pavucontrol ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      package = pkgs.wireplumber;
    };
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/nixos/Music";

    extraConfig = ''
      # must specify one or more outputs in order to play audio!
      # (e.g. ALSA, PulseAudio, PipeWire), see next sections
      audio_output {
        type "pipewire"
        name "My PipeWire Output"
      }
    '';

    # Optional:
    network.listenAddress = "any"; # if you want to allow non-localhost connections
    startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
  };
  # ===========================================================================
}
