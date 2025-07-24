{
  writeShellScriptBin,
  gnugrep,
  rsync,
  nvim,
  nvim-sandboxed,
  nvim-treesitter-install,
  name ? "nvim",
  nvimConfigDir ? "nvim",
  lua-config ? ../../config/dot_config/nvim,
}:

let
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

  FORCE_SYNC="false"
  FORCE_RESET_ONLY="false"
  FORCE_RESET="false"
  POSITIONAL_ARGS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force-reset)
        FORCE_RESET="true"
        shift
        ;;
      --force-reset-only)
        FORCE_RESET="true"
        FORCE_RESET_ONLY="true"
        shift
        ;;
      --force-sync)
        FORCE_SYNC="true"
        shift
        ;;
      -*)
        echo "Unknown option: $1"
        exit 1
        ;;
      *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
  done

  # Ensure clean environment for Neovim
  unset VIMINIT

  # Set up PATH to extras and Neovim.
  export PATH="${nvim-treesitter-install}/bin:${nvim-sandboxed}/bin:$PATH"
  export NVIM_APPNAME="${nvimConfigDir}"

  # Set up XDG directories if not already defined
  XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
  XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
  XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"

  nvimConfigDir="$XDG_CONFIG_HOME/$NVIM_APPNAME"
  nvimConfigDirSrc="$XDG_DATA_HOME/chezmoi/config/dot_config/nvim"

  if [ "$FORCE_RESET" = "true" ]; then
    echo "Force resetting NVIM config dirs."
    rm -rf "$XDG_CACHE_HOME/$NVIM_APPNAME" || true
    rm -rf "$XDG_DATA_HOME/$NVIM_APPNAME" || true
    rm -rf "$nvimConfigDir" || true

    if [ "$FORCE_RESET_ONLY" = "true" ]; then
      exit 0
    fi
  fi

  # Prepare Neovim configuration directory
  mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"

  # Check if nvim config needs to be copied.
  if [ ! -d "$nvimConfigDir" ]; then
    echo "Copying lua config '${lua-config}' to '$nvimConfigDir'"
    mkdir -p "$nvimConfigDir"
    cp -arfT '${lua-config}'/ "$nvimConfigDir"
    chmod -R u+w "$nvimConfigDir"
  fi

  # Check if treesitter needs updating.
  lock_file="$nvimConfigDir/lazy-lock.json"
  treesitter_rev="$nvimConfigDir/treesitter-rev"
  if ! "${gnugrep}/bin/grep" -q "${nvim-treesitter-install.rev}" "$lock_file"; then
    echo "Updating treesitter revision, cause not current with 'nvim-treesitter-install'."
    echo "${nvim-treesitter-install.rev}" > "$treesitter_rev"
    # Update plugins with Lazy package manager
    "${nvim}/bin/nvim" --headless "+Lazy! update" +qa

    # Sync back lock file etc.
    if [ -d "$XDG_DATA_HOME/chezmoi" ]; then
      cp  "$lock_file" "$XDG_DATA_HOME/chezmoi/config/dot_config/nvim/" || true
      cp  "$treesitter_rev" "$XDG_DATA_HOME/chezmoi/config/dot_config/nvim/" || true
    fi
  else
    # Just check and install plugins if needed
    "${nvim}/bin/nvim" --headless -c 'quitall'
  fi

  if [ "$FORCE_SYNC" = "true" ]; then
    echo "Syncing config to source directory."
    "${rsync}/bin/rsync" -av --delete "$nvimConfigDir/" "$nvimConfigDirSrc/"
  fi

  # Launch Neovim with all arguments passed to this script.
  echo
  echo "Starting ${nvim-sandboxed}"
  exec "${nvim-sandboxed}/bin/nvim" "''${POSITIONAL_ARGS[@]}"
''
