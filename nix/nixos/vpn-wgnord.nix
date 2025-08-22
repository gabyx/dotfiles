{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    getExe
    ;
  cfg = config.services.wgnord;

  preStart = pkgs.writeShellApplication {
    name = "wgnord-pre";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.libnotify
      cfg.package
    ];
    text = ''
      mkdir -p /var/lib/wgnord
      ln -s /etc/wgnord/template.conf /var/lib/wgnord/template.conf || true

      if [ ! -f "${cfg.tokenFile}" ]; then
        echo "Token file '${cfg.tokenFile}' not existing."
        exit 1
      fi

      # The login command is broken, returns exit code 1 even on success
      # We use '-' prefix to ignore this failure
      ${cfg.package}/bin/wgnord login "$(<${cfg.tokenFile})" || true
    '';
  };

  start = pkgs.writeShellApplication {
    name = "wgnord-start";
    runtimeInputs = [
      pkgs.libnotify
      cfg.package
      pkgs.curl
    ];
    text = ''
      country="''${NORDVPN_COUNTRY:-${cfg.country}}"
      echo "Connecting to '$country'."
      echo "IP Before: $(curl --connect-timeout 5 wtfismyip.com/text 2>/dev/null || true)"

      if ${getExe cfg.package} connect "$country"; then
        echo "Connected."
        echo "IP After: $(curl --connect-timeout 5 wtfismyip.com/text 2>/dev/null || true)"
      else
        echo "Connection failed."
        exit 1
      fi

      exit 0
    '';
  };

  stop = pkgs.writeShellApplication {
    name = "wgnord-stop";
    runtimeInputs = [
      pkgs.libnotify
      cfg.package
    ];
    text = ''
      if ${getExe cfg.package} disconnect; then
        echo "Disconnected."
      else
        echo "Disconnect failed."
      fi

      exit 0
    '';
  };

  wgnord-up = pkgs.writeShellApplication {
    name = "wgnord-up";
    runtimeInputs = [
      pkgs.systemd
    ];
    text = ''
      sudo systemctl set-environment NORDVPN_COUNTRY="''${1:-ch}"
      sudo systemctl start wgnord.service
      journalctl -u wgnord.service --no-pager -n 100
    '';
  };

  wgnord-down = pkgs.writeShellApplication {
    name = "wgnord-down";
    runtimeInputs = [
      pkgs.systemd
    ];
    text = ''
      sudo systemctl stop wgnord.service
    '';
  };

in
{
  options.services.wgnord = {
    enable = mkEnableOption "wgnord";

    package = mkOption {
      type = types.package;
      default = pkgs.wgnord;
      description = "The wgnord package to install";
    };

    tokenFile = mkOption {
      type = types.str;
      default = null;
      description = "Path to a file containing your NordVPN authentication token";
    };

    country = mkOption {
      type = types.str;
      default = "ch";
      description = ''
        The country which wgnord will try to connect
        to from https://github.com/phirecc/wgnord/blob/master/countries.txt
      '';
    };

    template = mkOption {
      type = types.str;
      default = ''
        [Interface]
        PrivateKey = PRIVKEY
        Address = 10.5.0.2/32
        MTU = 1350
        DNS = 103.86.96.100 103.86.99.100

        [Peer]
        PublicKey = SERVER_PUBKEY
        AllowedIPs = 0.0.0.0/0, ::/0
        Endpoint = SERVER_IP:51820
        PersistentKeepalive = 25
      '';
      description = "The Wireguard config";
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.wgnord
      pkgs.wireguard-tools

      wgnord-up
      wgnord-down
    ];

    systemd.services.wgnord = {
      unitConfig = {
        Description = "NordVPN Wireguard";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      serviceConfig = {
        Type = "oneshot";
        # https://discourse.nixos.org/t/creating-directories-and-files-declararively/9349/2
        StateDirectory = "wgnord";
        ExecStartPre = "${preStart}/bin/wgnord-pre";
        ExecStart = "${start}/bin/wgnord-start";
        ExecStop = "${stop}/bin/wgnord-stop";
        RemainAfterExit = "yes";
      };

      wantedBy = [ ];
    };

    environment.etc."wgnord/template.conf".text = cfg.template;

    systemd.tmpfiles.rules = [
      "d /etc/wireguard 0755 root root"
      "f /etc/wireguard/wgnord.conf 600 root root"
    ];
  };
}
