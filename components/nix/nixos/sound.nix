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
  services.pulseaudio.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [ pavucontrol ];

  users.users.${config.settings.user.name}.extraGroups = [
    "jackaudio"
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = false;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      package = pkgs.wireplumber;
    };
  };

  services.mpd = {
    enable = false;

    settings = {
      music_directory = "/home/nixos/Music";

      # Must specify one or more outputs in order to play audio!
      # (e.g. ALSA, PulseAudio, PipeWire), see next sections
      audio_output = {
        type = "pipewire";
        name = "My PipeWire Output";
      };

      bind_to_address = "any"; # if you want to allow non-localhost connections
    };

    startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
  };
  # ===========================================================================
}
