{
  pkgs,
  ...
}:
{
  imports = [
    ./networking-profiles
  ];

  networking = {
    nftables.enable = true;
    enableIPv6 = true;

    ### Networking ==============================================================
    networkmanager = {
      enable = true;
      plugins = [
        pkgs.networkmanager-openconnect
        pkgs.networkmanager-openvpn
      ];
    };

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    # ===========================================================================

    ### Firewall ================================================================
    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    # ===========================================================================
  };

  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDns = [
      # Cloudflare
      "1.1.1.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"

      # Google
      "8.8.8.8"
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
    ];
  };

  environment.systemPackages = with pkgs; [
    wirelesstools
    networkmanagerapplet
  ];
}
