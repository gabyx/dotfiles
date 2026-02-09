{ lib, pkgs, ... }:
{
  # Host: Make systemd-resolved listen on the container interface
  services.resolved = {
    enable = true;
    # extraConfig = ''
    #   # DNS=10.30.0.2
    #   # DNSStubListenerExtra=10.30.0.1  # Listen on container network
    #   # Domains=~.
    # '';
  };

  # Make systemd-resolved wait for the container
  # systemd.services.systemd-resolved = {
  #   after = [ "container@pihole.service" ];
  #   wants = [ "container@pihole.service" ];
  # };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-pihole" ]; # All container interfaces
  };

  networking.firewall.trustedInterfaces = [ "ve-pihole" ];

  # pihole DNS Web Service
  # Create a container for Pi-hole
  containers.pihole = {
    autoStart = false;

    # Give it a private network with its own IP

    privateNetwork = true;
    hostAddress = "10.30.0.1"; # Host-side IP
    localAddress = "10.30.0.2"; # Container IP (Pi-hole will use this)

    config =
      { ... }:
      {
        environment.systemPackages = [
          pkgs.curl
          pkgs.net-tools
        ];

        services.resolved.enable = true;

        systemd.services.test-pihole-curl = {
          description = "Looping curl test to ftl.pi-hole.net";
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.bash}/bin/bash -c "
              while true; do
                echo '--- curl attempt at ' $(date);
                ${pkgs.curl}/bin/curl -v --max-time 10 https://ftl.pi-hole.net || true;
                sleep 5;
              done
              "
            '';
          };
        };

        # Pi-hole configuration inside container
        # services.pihole-ftl = {
        #   enable = true;
        #   settings = {
        #     dns = {
        #       port = 53; # Can use standard port 53 now
        #       upstreams = [
        #         "1.1.1.1"
        #         "8.8.8.8"
        #       ]; # External DNS
        #     };
        #   };
        #   lists = [
        #     {
        #       url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        #     }
        #   ];
        # };
        #
        # services.pihole-web = {
        #   enable = true;
        #   ports = [
        #     "80r"
        #   ];
        # };
        #
        # systemd.services.pihole-ftl = {
        #   after = [ "systemd-resolved.service" ];
        #   wants = [ "systemd-resolved.service" ];
        # };

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [
            53
            80
          ];
          allowedUDPPorts = [ 53 ];
        };
        networking.useHostResolvConf = lib.mkForce false;

        system.stateVersion = "25.11";
      };
  };
}
