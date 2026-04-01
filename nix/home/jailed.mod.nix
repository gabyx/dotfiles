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

      readOnlyPaths =
        cs:
        lib.map (p: (cs.ro-bind (cs.noescape p) (cs.noescape p))) [
          # Configs
          "~/.config/fzf"
          "~/.config/git"
          "~/.config/git-town"
          "~/.config/hypr"
          "~/.config/lazygit"
          "~/.config/khal"
          "~/.config/kitty"
          "~/.config/lazygit"
          "~/.config/lf"
          "~/.config/nix"
          "~/.config/nixpkgs"
          "~/.config/process-compose"
          "~/.config/shell"
          "~/.config/tmux"
          "~/.config/wezterm"
          "~/.config/zathura"
          "~/.config/zsh"
          "~/.config/shell"
          "~/.config/nvim"
          "~/.config/nvim-nightly"

          "~/.ssh/sdsc-ordes-nix-cache-read"

          "~/.gitconfig"
          "~/.githooks"
          "~/.cargo"
          "~/.bashrc"
          "~/.zshenv"
          "~/.terminfo"

          # Share/State
          "~/.local/share/applications"
          "~/.local/share/nvim"
          "~/.local/share/nvim-nightly"
          "~/.local/share/delta"
          "~/.local/share/devenv"
          "~/.local/share/containers"
          "~/.local/share/k9s"
          "~/.local/share/nix"
          "~/.local/share/tig"
          "~/.local/share/uv"
          "~/.local/share/wezterm"

          "~/.local/state/nvim"
          "~/.local/state/nvim-nightly"
          "~/.local/state/lazygit"
          "~/.local/state/nix"
          "~/.local/state/nix-output-monitor"

          # Cache
          "~/.cache/go"
          "~/.cache/go-build"
          "~/.cache/golangci-lint"
          "~/.cache/goimports"
          "~/.cache/gopls"
          "~/.cache/kitty"
          "~/.cache/nix"
          "~/.cache/nix-alien"
          "~/.cache/nix-index"
          "~/.cache/nix-output-monitor"
          "~/.cache/nvim"
          "~/.cache/nvim-nightly"

          # Nix stuff
          "/etc/os-release"
          "/run/current-system/sw/bin"
          ''"/etc/profiles/per-user/$(id -un)"''
        ];

      writePaths =
        cs:
        lib.map (p: (cs.rw-bind (cs.noescape p) (cs.noescape p))) [
          "~/.config/zsh/.zsh_history"
        ];

      zsh-jailed = jailIt "zsh-jailed" pkgs.zsh (
        cs:
        [
          cs.gui
          cs.gpu
          cs.network
          cs.open-urls-in-browser

          (cs.ro-bind (cs.noescape "/nix/store") "/nix/store")
          (cs.readonly-paths-from-var "XDG_DATA_DIRS" ":")
          (cs.fwd-env "PATH")
          (cs.fwd-env "EDITOR")
          (cs.fwd-env "GITSTATUS_DAEMON")

          # Bind mounts based on arguments.
          (cs.add-runtime ''
            for arg in "$@"; do
              if [ -e "$arg" ]; then
                full_path=$(readlink -f "$arg")
                RUNTIME_ARGS+=(--bind "$full_path" "$full_path")
              fi
            done
          '')
        ]
        ++ (readOnlyPaths cs)
        ++ (writePaths cs)
      );

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
