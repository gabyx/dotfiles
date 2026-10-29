{ config, ... }:
{
  imports = [ ./vpn-wgnord.nix ];

  config = {
    # FIXME: Use proton vpn
    # VPN over nordvpn with wgnord.
    # services.wgnord = {
    #   enable = true;
    #   tokenFile = "${config.settings.user.home}/.config/nordvpn/token";
    #   country = "Switzerland";
    # };

    services.tailscale = {
      enable = config.settings.networking.vpn.tailscale.client.enable;
      # Only needed if you want to use exit nodes or subnet routes advertised by
      # other machines. Also sets the reverse-path filter to "loose" for you.
      useRoutingFeatures = "client";
    };
  };
}
