{
  lib,
  jail-nix,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  jailIt = jail-nix.lib.init pkgsUnstable;

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

      "~/.ssh/sdsc-ordes-nix-cache-read"

      "~/.gitconfig"
      "~/.githooks"
      "~/.cargo"
      "~/.bashrc"
      "~/.zshenv"
      "~/.terminfo"

      # Share/State
      "~/.local/share/applications"
      "~/.local/share/delta"
      "~/.local/share/devenv"
      "~/.local/share/containers"
      "~/.local/share/k9s"
      "~/.local/share/nix"
      "~/.local/share/tig"
      "~/.local/share/uv"
      "~/.local/share/wezterm"

      "~/.local/state/lazygit"
      "~/.local/state/nix"
      "~/.local/state/nix-output-monitor"

      # Nix stuff
      "/etc/os-release"
      "/run/current-system/sw/bin"
      ''"/etc/profiles/per-user/$(id -un)"''

    ];

  writePaths =
    cs:
    let
      extractSrcDest =
        p:
        if lib.isAttrs p then
          p
        else
          {
            src = p;
            dest = p;
          };
      makeBind =
        p:
        let
          b = extractSrcDest p;
        in
        cs.rw-bind (cs.noescape b.src) (cs.noescape b.src);
    in
    lib.map makeBind [
      {
        src = "~/.config/zsh/.zsh_history";
        dest = "/tmp/.zsh_history";
      }

      "~/.config/nvim"
      "~/.local/share/nvim"
      "~/.local/state/nvim"
      "~/.config/nvim-nightly"
      "~/.local/share/nvim-nightly"
      "~/.local/state/nvim-nightly"

      "~/.cache/nix"
      "~/.cache/go"
      "~/.cache/go-build"
      "~/.cache/golangci-lint"
      "~/.cache/goimports"
      "~/.cache/gopls"
      "~/.cache/kitty"
      "~/.cache/nix-alien"
      "~/.cache/nix-index"
      "~/.cache/nix-output-monitor"
      "~/.cache/nvim"
      "~/.cache/nvim-nightly"
    ];

  zsh-jailed = jailIt "zsh-jailed" pkgs.zsh (
    cs:
    [
      cs.network
      cs.open-urls-in-browser

      # Mount host store and use
      (cs.ro-bind (cs.noescape "/nix/store") "/nix/store")
      (cs.rw-bind "/nix/var/nix/daemon-socket/socket" "/nix/var/nix/daemon-socket/socket")
      (cs.set-env "NIX_REMOTE" "daemon")
      (cs.readonly-paths-from-var "XDG_DATA_DIRS" ":")
    ]
    ++ (readOnlyPaths cs)
    ++ (writePaths cs)
    ++ [
      (cs.set-env "JAILED" "true")
      (cs.fwd-env "PATH")
      (cs.fwd-env "EDITOR")
      (cs.fwd-env "GITSTATUS_DAEMON")
      (cs.set-env "CUSTOM_HISTFILE" "/tmp/.zsh_history")
      (cs.set-env "LOCALE_ARCHIVE" "${pkgs.glibcLocales}/lib/locale/locale-archive")

      # FIXME:
      # Nvim smart-split plugin does not detect the terminal.
      # It sends OSC sequence to the terminal but only if it detects it
      # Some missing pieces are not forwarding WEZTERM_ env vars.
      # use cs.add-runtime.
      # --setenv WEZTERM_PANE "$WEZTERM_PANE"
      # --setenv TERM_PROGRAM "$TERM_PROGRAM"
      # --setenv WEZTERM_UNIX_SOCKET "$WEZTERM_UNIX_SOCKET"

      # Bind mounts based on arguments.
      (cs.add-runtime ''
        for arg in "$@"; do
          shift

          if [ -e "$arg" ]; then
            full_path=$(readlink -f "$arg")
            echo "Bind mounting '$full_path'."
            RUNTIME_ARGS+=(--bind "$full_path" "$full_path")
          fi
        done
      '')
    ]
  );
in
{
  inherit zsh-jailed;
}
