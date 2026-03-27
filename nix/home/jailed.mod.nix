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

      zsh-jailed = jailIt "jail-shell" pkgs.zsh (cs: [
        cs.gui
        cs.gpu
        cs.network

        cs.open-urls-in-browser
        (cs.set-env "BROWSER" "browserchannel")

        (cs.ro-bind (cs.noescape "/nix/store") "/nix/store")
        (cs.ro-bind (cs.noescape "~/.config") (cs.noescape "~/.config"))
        (cs.fwd-env "PATH")
        (cs.readonly-paths-from-var "XDG_DATA_DIRS" ":")

        # Bind mounts based on arguments.
        (cs.add-runtime ''
          for arg in "$@"; do
            if [ -e "$arg" ]; then
              full_path=$(readlink -f "$arg")
              RUNTIME_ARGS+=(--bind "$full_path" "$full_path")

              RUNTIME_ARGS+=(
                --ro-bind
                "/etc/profiles/per-user/$(id -un)"
                "/etc/profiles/per-user/$(id -un)"
              )
            fi
          done
        '')
      ]);

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
      packages = {
        inherit signal-jailed;
        inherit zsh-jailed;
      };
    };
}
