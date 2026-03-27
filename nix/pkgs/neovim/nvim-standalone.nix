{
  writeShellScriptBin,
  rsync,
  jq,
  nvim,
  nvim-treesitter-install,
  name ? "nvim",
  nvimConfigName ? "",
  lua-config ? ../../../config/dot_config/nvim,
}:
let
  nvimAppName = if nvimConfigName == "" then name else nvimConfigName;
in
# Create a nvim startup script which checks for treesitter
# updates and uses a dedicated folder for nvim config `NVIM_APPNAME`.
#
# - If `--force-reset/--force-reset-only` is passed as first argument,
#   it will reset the whole installation.
# - If `--force-sync` is set, the config folder is synced back to the source directory.
writeShellScriptBin name ''
  #!/usr/bin/env bash
  set -efu

  DIRECT="false"
  FORCE_SYNC_BACK="false"
  FORCE_PLUGINS_UPDATE="true"
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
      --force-sync-back)
        FORCE_SYNC_BACK="true"
        shift
        ;;
      --force-no-plugin-update)
        FORCE_PLUGINS_UPDATE="false"
        shift
        ;;
      --help)
        echo "Use '--direct' to start nvim without doing anything." >&2
        echo "Use '--force-reset' to reset nvim and all cache/state folders." >&2
        echo "Use '--force-reset-only' to only reset and exit." >&2
        echo "Use '--force-sync-back' to sync ~/.config/nvim back to the Git repo." >&2
        echo "Use '--force-no-plugin-update' to do no plugin update." >&2
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
    export PATH="${nvim-treesitter-install}/bin:$PATH"
    export NVIM_APPNAME="''${NVIM_APPNAME:-${nvimAppName}}"

    # Set up XDG directories if not already defined
    export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
  }

  function reset() {
    echo "Force resetting NVIM config dirs."
    rm -rf "$XDG_CACHE_HOME/$NVIM_APPNAME" || true
    rm -rf "$XDG_DATA_HOME/$NVIM_APPNAME" || true
    rm -rf "$XDG_STATE_HOME/$NVIM_APPNAME" || true
    rm -rf "$nvimConfigDir" || true

    if [ "$FORCE_RESET_ONLY" = "true" ]; then
      exit 0
    fi
  }

  function plugin_update() {
    lock_file="$nvimConfigDir/lazy-lock.json"
    treesitter_rev="$nvimConfigDir/treesitter-rev"

    if [ ! -f "$lock_file" ]; then
      echo "Lock file '$lock_file' is not existing."
      return 0
    fi

    # Check if treesitter needs updating.
    local rev=$("${jq}/bin/jq" -r '.["nvim-treesitter"].commit' "$lock_file") || true

    if [ "$rev" != "${nvim-treesitter-install.rev}" ]; then
      echo "Updating nvim-treesitter plugin revision, cause not current with " \
            "'nvim-treesitter-install.rev = ${nvim-treesitter-install.rev}'."

      "${jq}/bin/jq" \
        '.["nvim-treesitter"].commit |= "${nvim-treesitter-install.rev}"' \
        "$lock_file" > "$lock_file.tmp" &&
        mv "$lock_file.tmp" "$lock_file"

      # Sync back lock file etc.
      if [ -d "$XDG_DATA_HOME/chezmoi" ]; then
        echo "Syncing back lock files and treesitter revision."
        cp  "$lock_file" "$nvimConfigDirSrc/" || true
      fi

      # Update plugins with Lazy package manager
      "${nvim}/bin/nvim" --headless "+Lazy! restore" +qa || {
        echo "Could not update 'nvim' plugins."
      }
    else
      echo "Not updating nvim-treesitter plugin revision, cause current with " \
            "'nvim-treesitter-install.rev = ${nvim-treesitter-install.rev}'."

      # Just check and install plugins if needed
      "${nvim}/bin/nvim" --headless -c 'quitall' || {
        echo "Could not check and install 'nvim' plugins."
      }
    fi
  }

  function sync_config() {

    if [ "$(cat "$nvimConfigDir/.nix-version" 2>/dev/null)" != "${lua-config}" ]; then
      echo "Copying lua config '${lua-config}' to '$nvimConfigDir'"
      mkdir -p "$nvimConfigDir"
      "${rsync}/bin/rsync" --info=progress2 -av --delete "${lua-config}/" "$nvimConfigDir/"
      chmod -R u+w "$nvimConfigDir"

      echo -n "${lua-config}" > "$nvimConfigDir/.nix-version"
    else
      echo "Lua configs up-to-date."
    fi

    echo -n "${nvim-treesitter-install.rev}" > "$nvimConfigDir/.treesitter-rev"
  }

  function sync_back() {
    echo "Syncing config to source directory."
    "${rsync}/bin/rsync" --info=progress2 -av --no-times --delete \
      --exclude ".nix-version" \
      --exclude ".treesitter-rev" \
      "$nvimConfigDir/" "$nvimConfigDirSrc/"
  }

  set_env

  mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"
  nvimConfigDir="$XDG_CONFIG_HOME/$NVIM_APPNAME"
  nvimConfigDirSrc="$XDG_DATA_HOME/chezmoi/config/dot_config/nvim"
  echo "nvimConfigDir: '$nvimConfigDir'"

  if [ "$DIRECT" = "true" ]; then
    echo "Just start nvim '${nvim}'."
    exec "${nvim}/bin/nvim" "''${NVIM_ARGS[@]}"
  fi

  if [ "$FORCE_RESET" = "true" ]; then
    reset
  fi

  sync_config

  if [ "$FORCE_PLUGINS_UPDATE" = "true" ]; then
    plugin_update
  fi

  if [ "$FORCE_SYNC_BACK" = "true" ]; then
    sync_back
  fi

  echo
  echo "Starting '${nvim}'" "''${NVIM_ARGS[@]}"
  exec "${nvim}/bin/nvim" "''${NVIM_ARGS[@]}"
''
