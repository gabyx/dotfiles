{ config, ... }:
{
  imports = [ ./vpn-wgnord.nix ];

  config = {
    # VPN over nordvpn with wgnord.
    services.wgnord = {
      enable = true;
      tokenFile = "${config.settings.user.home}/.config/nordvpn/token";
      country = "Switzerland";
    };
  };
}
