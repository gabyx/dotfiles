{ config, pkgsUnstable, ... }:
{
  imports = [ ./vpn-wgnord.nix ];

  config = {
    services.tailscale = {
      package = pkgsUnstable.tailscale;
      enable = config.settings.networking.vpn.tailscale.client.enable;

      # Only needed if you want to use exit nodes or subnet routes advertised by
      # other machines. Also sets the reverse-path filter to "loose" for you.
      # useRoutingFeatures = "client";
    };
  };
}
