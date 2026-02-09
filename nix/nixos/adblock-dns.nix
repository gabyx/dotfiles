{ lib, pkgs, ... }:
{
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS=127.0.0.10:5350
    '';
    fallbackDns = lib.mkForce [ ];
  };

  networking.networkmanager = {
    dns = lib.mkForce "none";
    settings = {
      main = {
        systemd-resolved = false;
      };
    };
  };

  services.adguardhome = {
    enable = true;
    mutableSettings = true;

    # Web interface.
    host = "127.0.0.1";
    port = 5353;

    settings = {
      dns = {
        bind_hosts = [ "127.0.0.10" ];
        port = 5350;

        upstream_dns = [
          # "127.0.0.53" # systemd-resolved
          "192.168.178.1"
          "fd00::f2b0:14ff:fe6a:2cab"
          "2001:8e0:3bc2:5801:f2b0:14ff:fe6a:2cab"
        ];

        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
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
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_24.txt"
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_70.txt"
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt"
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt"
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt"
          ];
    };
  };
}
