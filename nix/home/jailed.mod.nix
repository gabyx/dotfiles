{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, pkgsUnstable, ... }:
    let
      jailIt = inputs.jail-nix.lib.init pkgsUnstable;

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
        in
        pkgs.runCommand name { } ''
          mkdir $out
          ln -s ${jailed}/bin $out/bin
          mkdir -p $out/share
          # ln -s ${pkg}/share/icon $out/share/icon

          ln -s ${
            pkgs.writeTextFile {
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
            }
          } $out/share/
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
          combinators: with combinators; [
            network
            gui
            gpu
            camera
            open-urls-in-browser
            (readwrite "/run/dbus/system_bus_socket")
            (readwrite (noescape "~/.config/Signal"))
            (try-readwrite (noescape "~/Downloads"))

            (dbus {
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
      packages = {
        inherit signal-jailed;
      };
    };
}
