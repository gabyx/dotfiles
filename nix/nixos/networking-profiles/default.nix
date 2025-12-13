{
  config,
  ...
}:
{
  age.secrets = {
    networkmanager-secrets.file = ../secrets/networkmanager-secrets.env.age;
  };

  # This settings can be get from:
  #
  # sudo su -c "cd /etc/NetworkManager/system-connections && nix --extra-experimental-features 'nix-command flakes' run github:Janik-Haag/nm2nix | nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixfmt-rfc-style"
  networking.networkmanager = {
    ensureProfiles = {
      environmentFiles = [
        config.age.secrets.networkmanager-secrets.path
      ];
      profiles = {
        oidaleck = {
          connection = {
            id = "OidaLeck";
            interface-name = "wlp2s0";
            type = "wifi";
            uuid = "09ac7dff-a7ea-41c3-a662-0dbd4b4c32eb";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "OidaLeck";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$OIDALECK_PASSWD";
          };
        };
        oidaleck5 = {
          connection = {
            id = "OidaLeck5Ghz";
            interface-name = "wlp2s0";
            type = "wifi";
            uuid = "0e4b1cb3-b3f4-4266-8e9a-16b18eb9f148";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "OidaLeck5Ghz";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$OIDALECK_PASSWD";
          };
        };
        sbb-free = {
          connection = {
            id = "SBB-FREE";
            interface-name = "wlp2s0";
            type = "wifi";
            uuid = "8dc8baea-49da-4640-b785-8913c2916a2c";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "SBB-FREE";
          };
        };
        sdsc-zurich-ethernet = {
          "802-1x" = {
            eap = "peap;";
            identity = "$SDSC_ZURICH_IDENTITY";
            password = "$SDSC_ZURICH_PASSWD";
            phase2-auth = "mschapv2";
          };
          connection = {
            autoconnect-priority = "-999";
            id = "sdsc-zurich-ethernet";
            interface-name = "enp6s0f3u1u6";
            timestamp = "1718019060";
            type = "ethernet";
            uuid = "beb840e9-0ac3-3938-a606-792cffcd39db";
          };
          ethernet = { };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = { };
        };
        eth-zurich-vpn = {
          connection = {
            id = "eth-zurich-vpn";
            autoconnect = "false";
            timestamp = "1745873064";
            type = "vpn";
            uuid = "6dfa273e-f299-4afc-aee2-d58aaa96c590";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = { };
          vpn = {
            authtype = "password";
            autoconnect-flags = "0";
            certsigs-flags = "0";
            cookie-flags = "2";
            disable_udp = "no";
            enable_csd_trojan = "no";
            gateway = "sslvpn.ethz.ch";
            gateway-flags = "2";
            gwcert-flags = "2";
            lasthost-flags = "0";
            pem_passphrase_fsid = "no";
            prevent_invalid_cert = "no";
            protocol = "anyconnect";
            resolve-flags = "2";
            service-type = "org.freedesktop.NetworkManager.openconnect";
            stoken_source = "disabled";
            xmlconfig-flags = "0";
          };
          vpn-secrets = {
            "form:main:group_list" = "staff-net";
            "form:main:username" = "$SDSC_ZURICH_IDENTITY";
            lasthost = "sslvpn.ethz.ch";
            xmlconfig = "$ETH_ZURICH_VPN_XML_CONFIG";
          };
        };
        sdsc-eduroam = {
          "802-1x" = {
            anonymous-identity = "anonymous@ethz.ch";
            eap = "peap;";
            identity = "$SDSC_ZURICH_IDENTITY";
            password = "$SDSC_ZURICH_PASSWD";
            phase2-auth = "mschapv2";
          };
          connection = {
            id = "sdsc-eduroam";
            interface-name = "wlp2s0";
            type = "wifi";
            uuid = "f7153a97-4a36-4e21-852b-6c2e15005123";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "eduroam";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
        };
        sdsc-lausanne-eduroam = {
          "802-1x" = {
            anonymous-identity = "anonymous@ethz.ch";
            ca-cert = "${./DigiCertGlobalRootG2.crt.pem}";
            eap = "peap;";
            identity = "$SDSC_ZURICH_IDENTITY";
            password = "$SDSC_ZURICH_PASSWD";
            phase2-auth = "mschapv2";
          };
          connection = {
            id = "sdsc-lausanne-eduroam";
            interface-name = "wlp2s0";
            type = "wifi";
            uuid = "7a247b55-b554-49f5-adfb-8685b2599d15";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "eduroam";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
        };
        sdsc-zurich-eduroam = {
          "802-1x" = {
            eap = "ttls;";
            identity = "$SDSC_ZURICH_IDENTITY";
            password = "$SDSC_ZURICH_PASSWD";
            phase2-auth = "mschapv2";
          };
          connection = {
            id = "sdsc-zurich-eduroam";
            interface-name = "wlp2s0";
            timestamp = "1718017960";
            type = "wifi";
            uuid = "73a422d5-77f1-4db3-bb47-850e0efb2966";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "eduroam";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
        };
        gabyx-iphone = {
          connection = {
            autoconnect-priority = "999";
            id = "gabyx-iphone";
            interface-name = "wlp2s0";
            timestamp = "1750353298";
            type = "wifi";
            uuid = "89322850-91c4-4b66-a6c6-b112a771c57b";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            ssid = "gabyx-iphone";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$GABYX_IPHONE_PASSWD";
          };
        };
        gabyx-iphone-bluetooth = {
          bluetooth = {
            bdaddr = "64:70:33:21:06:E1";
            type = "panu";
          };
          connection = {
            autoconnect-priority = "999";
            id = "gabyx-iphone-bluetooth";
            timestamp = "1742975231";
            type = "bluetooth";
            uuid = "bac55023-a3ea-4397-8774-0765c98ee572";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          proxy = { };
        };
      };
    };
  };
}
