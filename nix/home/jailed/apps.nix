{
  lib,
  pkgs,
  pkgsUnstable,
  jail-nix,
  ...
}:
let
  jailIt = jail-nix.lib.init pkgsUnstable;

  jailApp =
    {
      name,
      pkg,
      args,
      jail,
      desktop,
    }:
    let
      jailed = jailIt name pkg jail;
      desktopFile = pkgs.writeTextFile {
        name = "${name}-desktop";
        destination = "/applications/${name}.desktop";
        text = ''
          [Desktop Entry]
          Name=${name} (jailed)
          Exec=${lib.getExe jailed} ${args}
          Terminal=false
          Type=Application
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${v}") desktop)}
        '';
      };
    in
    pkgs.runCommand name { } ''
      mkdir $out
      ln -s ${jailed}/bin $out/bin
      mkdir -p $out/share
      # ln -s ${pkg}/share/icon $out/share/icon

      ln -s ${desktopFile} $out/share/
    '';

  signal-jailed = jailApp {
    name = "signal-desktop";
    pkg = pkgsUnstable.signal-desktop-bin;
    args = "-s %U";
    desktop = {
      Terminal = "false";
      Icon = "signal-desktop";
      StartupWMClass = "signal";
      Comment = "Private messaging from your desktop";
      MimeType = "x-scheme-handler/sgnl;x-scheme-handler/signalcaptcha;";
      Categories = "Network;InstantMessaging;Chat;";
    };
    jail = (
      cs: [
        cs.network
        cs.gui
        cs.gpu
        cs.camera
        cs.open-urls-in-browser
        (cs.readwrite "/run/dbus/system_bus_socket")
        (cs.readwrite (cs.noescape "~/.config/Signal"))
        (cs.try-readwrite (cs.noescape "~/Downloads"))

        (cs.dbus {
          talk = [
            "org.freedesktop.DBus"
            "org.freedesktop.portal.*"
          ];
        })
      ]
    );
  };
in
{
  inherit signal-jailed;
}
