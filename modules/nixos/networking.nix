{
  config,
  pkgs,
  ...
}:
{
  networking = {
    ### Networking ==============================================================
    hostName = "linux-nixos"; # Define your hostname.
    networkmanager.enable = true;
    # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    # interfaces.enp4s0.useDHCP = true;
    # interfaces.wlp3s0.useDHCP = true;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    # ===========================================================================

    ### Firewall ================================================================
    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [
        50022
        433
      ];
      # allowedUDPPorts = [ ... ];
    };
    # ===========================================================================
  };

  environment.systemPackages = with pkgs; [
    wirelesstools
    networkmanagerapplet
  ];
}
