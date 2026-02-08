{ lib, ... }:
{
  networking.networkmanager = {
    dns = lib.mkForce "none";
  };

  # Host: Make systemd-resolved listen on the container interface
  services.resolved = {
    enable = true;
    extraConfig = ''
      # DNS=10.30.0.2
      DNSStubListenerExtra=10.30.0.1  # Listen on container network
      Domains=~.
    '';
  };

  # Make systemd-resolved wait for the container
  # systemd.services.systemd-resolved = {
  #   after = [ "container@pihole.service" ];
  #   wants = [ "container@pihole.service" ];
  # };

  # pihole DNS Web Service
  # Create a container for Pi-hole
  containers.pihole = {
    autoStart = true;

    # Give it a private network with its own IP
    privateNetwork = true;
    hostAddress = "10.30.0.1"; # Host-side IP
    localAddress = "10.30.0.2"; # Container IP (Pi-hole will use this)

    config =
      { ... }:
      {
        # Pi-hole configuration inside container
        services.pihole-ftl = {
          enable = true;
          settings = {
            dns = {
              port = 53; # Can use standard port 53 now
              upstreams = [
                "1.1.1.1"
                "8.8.8.8"
              ]; # External DNS
            };
          };
          lists = [
            {
              url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            }
          ];
        };

        services.pihole-web = {
          enable = true;
          ports = [
            "80r"
            "443s"
          ];
        };

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [
            53
            80
          ];
          allowedUDPPorts = [ 53 ];
        };
      };
  };
}
