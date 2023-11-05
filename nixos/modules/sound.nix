{ config, pkgs, ... }:

{
  ### Sound Settings ==========================================================
  sound.enable = true;

  security.rtkit.enable = true;
  
  # Disable Pulseaudio because Pipewire is used.
  hardware.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [
		pavucontrol pulseaudio
	];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = false;
  };
  # ===========================================================================
}
