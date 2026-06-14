{
  lib,
  writeShellScriptBin,
  nvim,
  name ? "nvim",
  nvimConfigName ? "",
}:
let
  nvimAppName = if nvimConfigName == "" then name else nvimConfigName;
in
# Create a nvim startup script which updates the
# dedicated folder for nvim config `NVIM_APPNAME`.
#
# - If `--force-reset/--force-reset-only` is passed as first argument,
#   it will reset the whole installation.
(writeShellScriptBin name ''
  #!/usr/bin/env bash
  set -efu

  DIRECT="false"
  FORCE_SYNC_BACK="false"
  FORCE_RESET_ONLY="false"
  FORCE_RESET="false"
  NVIM_ARGS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --direct)
        DIRECT="true"
        shift
        ;;
      --force-reset)
        FORCE_RESET="true"
        shift
        ;;
      --force-reset-only)
        FORCE_RESET="true"
        FORCE_RESET_ONLY="true"
        shift
        ;;
      --help)
        echo "Use '--direct' to start nvim without doing anything." >&2
        echo "Use '--force-reset' to reset nvim and all cache/state folders." >&2
        echo "Use '--force-reset-only' to only reset and exit." >&2
        exit 0
        ;;
      --)
        shift
        NVIM_ARGS+=("$@")
        break
        ;;
      *)
        NVIM_ARGS+=("$1")
        shift
        ;;
    esac
  done

  function set_env() {
    # Ensure clean environment for Neovim
    unset VIMINIT

    # Set up PATH to extras and Neovim.
    export NVIM_APPNAME="''${NVIM_APPNAME:-${nvimAppName}}"

    # Set up XDG directories if not already defined
    export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"

    echo "NVIM_APPNAME: '$NVIM_APPNAME'"
  }

  function reset() {
    echo "Force resetting NVIM config dirs."

    echo "Would remove: "
    echo " - '$XDG_CACHE_HOME/$NVIM_APPNAME'"
    echo " - '$XDG_DATA_HOME/$NVIM_APPNAME'"
    echo " - '$XDG_STATE_HOME/$NVIM_APPNAME'"
    echo " - '$nvimConfigDir'"

    printf "Should I do it? [yN]: "
    read answer
    if [ "$answer" != "y" ]; then
      return 0
    fi

    echo "Removing..."
    rm -rf "$XDG_CACHE_HOME/$NVIM_APPNAME" || true
    rm -rf "$XDG_DATA_HOME/$NVIM_APPNAME" || true
    rm -rf "$XDG_STATE_HOME/$NVIM_APPNAME" || true
    rm -rf "$nvimConfigDir" || true

    if [ "$FORCE_RESET_ONLY" = "true" ]; then
      exit 0
    fi
  }

  set_env

  mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"
  nvimConfigDir="$XDG_CONFIG_HOME/$NVIM_APPNAME"
  echo "nvimConfigDir: '$nvimConfigDir'"

  if [ "$DIRECT" = "true" ]; then
    echo "Just start nvim '${nvim}'."
    exec "${lib.getExe nvim}" "''${NVIM_ARGS[@]}"
  fi

  if [ "$FORCE_RESET" = "true" ]; then
    reset
  fi

  echo
  echo "Starting '${nvim}'" "''${NVIM_ARGS[@]}"
  exec "${lib.getExe nvim}" "''${NVIM_ARGS[@]}"
'').overrideAttrs
  { passthru = { inherit (nvim.passthru) neovimConfig; }; }
