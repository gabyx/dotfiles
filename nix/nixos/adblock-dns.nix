{ lib, pkgs, ... }:
{
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS=127.0.0.1
    '';
  };

  networking.networkmanager = {
    dns = lib.mkForce "none";
  };

  services.adguardhome = {
    enable = true;
    # Web interface.
    host = "127.0.0.1";
    port = 5353;

    settings = {
      dns = {
        bind_hosts = [ "127.0.0.1" ];
        port = 53;

        upstream_dns = [
          "127.0.0.53" # systemd-resolved
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false; # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false; # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters =
        map
          (url: {
            enabled = true;
            url = url;
          })
          [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
          ];
    };
  };
}
